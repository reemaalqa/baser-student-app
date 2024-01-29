import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/data/repositories/subjectRepository.dart';
import 'package:eschool/utils/errorMessageKeysAndCodes.dart';
import 'package:external_path/external_path.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class DownloadFileState {}

class DownloadFileInitial extends DownloadFileState {}

class DownloadFileInProgress extends DownloadFileState {
  final double uploadedPercentage;

  DownloadFileInProgress(this.uploadedPercentage);
}

class DownloadFileSuccess extends DownloadFileState {
  final String downloadedFileUrl;

  DownloadFileSuccess(this.downloadedFileUrl);
}

class DownloadFileProcessCanceled extends DownloadFileState {}

class DownloadFileFailure extends DownloadFileState {
  final String errorMessage;
  final bool isMessageKey;

  DownloadFileFailure(this.errorMessage, {this.isMessageKey = false});
}

class DownloadFileCubit extends Cubit<DownloadFileState> {
  final SubjectRepository _subjectRepository;

  DownloadFileCubit(this._subjectRepository) : super(DownloadFileInitial());

  final CancelToken _cancelToken = CancelToken();

  void _downloadedFilePercentage(double percentage) {
    emit(DownloadFileInProgress(percentage));
  }

  Future<void> writeFileFromTempStorage({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final tempFile = File(sourcePath);
    final byteData = await tempFile.readAsBytes();
    final downloadedFile = File(destinationPath);
    //write into downloaded file
    await downloadedFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
  }

  Future<void> downloadFile({
    required StudyMaterial studyMaterial,
  }) async {
    emit(DownloadFileInProgress(0.0));
    try {
      //if wants to download the file then
      Future<void> thingsToDoAfterPermissionIsGiven(
          bool isPermissionGranted) async {
        //storing the fie temp
        final Directory tempDir = await getTemporaryDirectory();
        final tempFileSavePath =
            "${tempDir.path}/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

        //if same name file is already there, just open it by emitting success
        if (await File(tempFileSavePath).exists()) {
          emit(DownloadFileSuccess(tempFileSavePath));
          return;
        }

        await _subjectRepository.downloadStudyMaterialFile(
          cancelToken: _cancelToken,
          savePath: tempFileSavePath,
          updateDownloadedPercentage: _downloadedFilePercentage,
          url: studyMaterial.fileUrl,
        );

        //download file
        String downloadFilePath = Platform.isAndroid && isPermissionGranted
            ? (await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS,
        ))
            : (await getApplicationDocumentsDirectory()).path;

        downloadFilePath =
        "$downloadFilePath/${studyMaterial.fileName}.${studyMaterial.fileExtension}";

        await writeFileFromTempStorage(
          sourcePath: tempFileSavePath,
          destinationPath: downloadFilePath,
        );

        emit(DownloadFileSuccess(downloadFilePath));
      }

      //if user has given permission to download and view file
      final permission = await Permission.storage.request();
      if (permission.isGranted) {
        await thingsToDoAfterPermissionIsGiven(true);
      } else {
        try {
          await thingsToDoAfterPermissionIsGiven(false);
        } catch (e) {
          if (e.toString() == ErrorMessageKeysAndCode.fileNotFoundErrorCode) {
            emit(
              DownloadFileFailure(
                ErrorMessageKeysAndCode.getErrorMessageKeyFromCode(
                    ErrorMessageKeysAndCode.fileNotFoundErrorCode),
                isMessageKey: true,
              ),
            );
          } else {
            emit(
              DownloadFileFailure(
                e.toString(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (_cancelToken.isCancelled) {
        emit(DownloadFileProcessCanceled());
      } else {
        emit(DownloadFileFailure(e.toString()));
      }
    }
  }

  void cancelDownloadProcess() {
    _cancelToken.cancel();
  }
}
