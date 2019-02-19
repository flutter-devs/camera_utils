package com.aeologic.camerautils;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.util.Log;
import android.widget.Toast;

import com.aeologic.camerautils.constant.Constants;
import com.aeologic.camerautils.util.Utils;
import com.karumi.dexter.Dexter;
import com.karumi.dexter.MultiplePermissionsReport;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.multi.MultiplePermissionsListener;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.app.Activity.RESULT_OK;

/** CameraUtilsPlugin */
public class CameraUtilsPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener {

  private static final String TAG = CameraUtilsPlugin.class.getSimpleName();
  private static final String METHOD_CHANNEL = "camera_utils";
  private Result result;
  private static final int REQUEST_CAPTURE_IMAGE = 101;
  private static final int REQUEST_PICK_IMAGE = 102;
  private static final int REQUEST_CAPTURE_VIDEO = 201;
  private static final int REQUEST_PICK_VIDEO = 202;

  private int SELECTED_ID = 0;

  private Activity activity;
  private File mediaStorageDir;
  private File mediaFile;
  private Uri uri;
  private String _CAPTURE_IMAGE_NAME = "IMAGE_";


  public CameraUtilsPlugin(Activity activity) {
    this.activity = activity;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), METHOD_CHANNEL);
    CameraUtilsPlugin cameraPlugin = new CameraUtilsPlugin(registrar.activity());
    registrar.addActivityResultListener(cameraPlugin);
    channel.setMethodCallHandler(cameraPlugin);
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    this.result = result;
    if (call.method.equals("captureImage")) {
      SELECTED_ID = REQUEST_CAPTURE_IMAGE;
      checkPermission();
    } else if (call.method.equals("pickImage")) {
      SELECTED_ID = REQUEST_PICK_IMAGE;
      checkPermission();
    } else if (call.method.equals("captureVideo")) {
      SELECTED_ID = REQUEST_CAPTURE_VIDEO;
      checkPermission();
    } else if (call.method.equals("pickVideo")) {
      SELECTED_ID = REQUEST_PICK_VIDEO;
      checkPermission();
    } else if (call.method.equals("getFileName")) {
      String path = call.argument("path");
      result.success(Utils.getFileName(path));
    } else if (call.method.equals("getFileNameWithoutExt")) {
      String path = call.argument("path");
      result.success(Utils.getFileNameWithoutExtension(new File(path)));
    } else if (call.method.equals("getThumbnail")) {
      final String path = call.argument("path");
      new Handler().post(new Runnable() {
        @TargetApi(Build.VERSION_CODES.FROYO)
        @Override
        public void run() {
          Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(new File(path).getAbsolutePath(), MediaStore.Video.Thumbnails.MINI_KIND);
          File file = null;
          try {
            file = Utils.getFileFromBitmap(activity, bitmap, path);
            Log.v("FILE: ", "NAME: " + file.getName() + "\nSIZE: " + file.length());
            result.success(file.getPath());
          } catch (IOException e) {
            e.printStackTrace();
            result.success(null);
          }
        }
      });

    } else if (call.method.equals("writeTextToImage")) {
      final String path = call.argument("path");
      final String content = call.argument("content");
      new Handler().post(new Runnable() {
        @Override
        public void run() {
          Bitmap tempBmp = Utils.getBitmapFromFile(new File(path));
          Bitmap bmp = Utils.drawTextToBitmap(activity, tempBmp, "Deepak Nishad");
          String finalPath = Utils.saveFileToStorage(path, bmp);
          Log.v("FINAL_PATH", "FINAL_PATH: " + finalPath);
          result.success(finalPath);

                    /*try {
                        File file=Utils.drawTextToBitmap(activity, new File(path), content, Color.TRANSPARENT);
                        Log.v("FILE: ", "NAME: " + file.getName() + "\nSIZE: " + file.length());
                        result.success(file.getPath());
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                        result.success(null);
                    }
                    Bitmap bitmap = Utils.getBitmapFromFile(new File(path));
                    if (bitmap != null) {
                        bitmap = Utils.drawTextToBitmap(activity, bitmap, content, Color.TRANSPARENT);
                        File file = null;
                        try {
                            file = Utils.getFileFromBitmap(activity, bitmap, path);
                            Log.v("FILE: ", "NAME: " + file.getName() + "\nSIZE: " + file.length());
                            result.success(file.getPath());
                        } catch (IOException e) {
                            e.printStackTrace();
                            result.success(null);
                        }
                    }*/
        }
      });

    } else {
      result.notImplemented();
    }
  }

  private void checkPermission() {
    Dexter.withActivity(activity)
            .withPermissions(
                    Manifest.permission.CAMERA,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
            ).withListener(new MultiplePermissionsListener() {
      @Override
      public void onPermissionsChecked(MultiplePermissionsReport report) {
        if (report.areAllPermissionsGranted()) {
          if (SELECTED_ID == REQUEST_CAPTURE_IMAGE) {
            captureImage();
          } else if (SELECTED_ID == REQUEST_PICK_IMAGE) {
            pickImage();
          } else if (SELECTED_ID == REQUEST_CAPTURE_VIDEO) {
            captureVideo();
          } else if (SELECTED_ID == REQUEST_PICK_VIDEO) {
            pickVideo();
          }
        } else {
          Toast.makeText(activity, "Please grant all permissions!", Toast.LENGTH_SHORT).show();
        }
      }

      @Override
      public void onPermissionRationaleShouldBeShown(List<com.karumi.dexter.listener.PermissionRequest> permissions, PermissionToken token) {
        token.continuePermissionRequest();
      }
    }).check();
  }

  private void captureImage() {
    mediaStorageDir = new File(Environment.getExternalStorageDirectory(), Constants.IMAGES);
    if (!mediaStorageDir.exists()) {
      if (!mediaStorageDir.mkdirs()) {
        Log.e("DIR_CREATION", "Failed to create directory!");
      }
    }
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    mediaFile = new File(mediaStorageDir.getPath() + File.separator + _CAPTURE_IMAGE_NAME + new SimpleDateFormat(Constants.TIMESTAMP_FORMAT).format(new Date()) + Constants.PNG);
    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
      uri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".flutter.provider", mediaFile);
      Log.v(TAG, uri.toString());

    } else {
      uri = Uri.fromFile(mediaFile);
    }
    intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
    activity.startActivityForResult(intent, REQUEST_CAPTURE_IMAGE);
  }

  private void pickImage() {
    Intent galleryIntent = new Intent(Intent.ACTION_PICK,
            android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
    if (galleryIntent.resolveActivity(activity.getPackageManager()) != null) {
      activity.startActivityForResult(galleryIntent, REQUEST_PICK_IMAGE);
    }
  }

  private void captureVideo() {
    Log.v(TAG, "CAPTURE_VIDEO");
    Intent takeVideoIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
    if (takeVideoIntent.resolveActivity(activity.getPackageManager()) != null) {
      activity.startActivityForResult(takeVideoIntent, REQUEST_CAPTURE_VIDEO);
    }
  }

  private void pickVideo() {
    Intent galleryIntent = new Intent(Intent.ACTION_PICK,
            android.provider.MediaStore.Video.Media.EXTERNAL_CONTENT_URI);
    if (galleryIntent.resolveActivity(activity.getPackageManager()) != null) {
      activity.startActivityForResult(galleryIntent, REQUEST_PICK_VIDEO);
    }
  }


  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
    Log.v(TAG, "onActivityResult()");
    if (resultCode == RESULT_OK && requestCode == REQUEST_CAPTURE_IMAGE) {
      if (uri != null && uri.getPath() != null) {
        result.success(uri.getPath());
        return true;
      } else {
        result.success(null);
        Toast.makeText(activity, "Process Failed...", Toast.LENGTH_SHORT).show();
      }
    } else if (resultCode == RESULT_OK && (requestCode == REQUEST_PICK_IMAGE || requestCode == REQUEST_CAPTURE_VIDEO || requestCode == REQUEST_PICK_VIDEO)) {
      if (intent != null) {
        String path = null;
        Uri uri = intent.getData();
        if (uri != null && uri.getPath() != null) {
          Log.v(TAG, "URI: " + uri.toString());
          if (SELECTED_ID == REQUEST_PICK_IMAGE)
            path = getPath(uri, new String[]{MediaStore.Images.Media.DATA});
          else if (SELECTED_ID == REQUEST_CAPTURE_VIDEO || SELECTED_ID == REQUEST_PICK_VIDEO)
            path = getPath(uri, new String[]{MediaStore.Video.Media.DATA});

          Log.v(TAG, "PATH: " + path);
        }
        result.success(path);
        return true;
      } else {
        Toast.makeText(activity, "Process Failed...", Toast.LENGTH_SHORT).show();
        result.success(null);
      }
    }

    return false;
  }

  private String getPath(Uri uri, String[] projection) {
    Cursor cursor = activity.getContentResolver().query(uri, projection, null, null, null);
    if (cursor != null) {
      int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
      cursor.moveToFirst();
      return cursor.getString(column_index);
    } else
      return null;
  }
}
