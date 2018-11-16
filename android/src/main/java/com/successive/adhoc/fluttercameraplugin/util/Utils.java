package com.successive.adhoc.fluttercameraplugin.util;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.os.Environment;
import android.renderscript.ScriptC;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.util.Log;
import android.widget.TextView;

import com.successive.adhoc.fluttercameraplugin.constant.Constants;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;

public class Utils {

    public static File getFileFromBitmap(Context context, String path) throws IOException {
        File imageFile = null;
        File currentFile = new File(path);
        OutputStream os = null;
        try {
            imageFile = new File(currentFile.getParent(), getFileNameWithoutExtension(currentFile) + Constants.EXT_PNG);
            os = new FileOutputStream(imageFile);

            // Get Bitmap
            Bitmap bitmap=getBitmapFromFile(new File(path));
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, os);
            Log.v("PATH: ", imageFile.getAbsolutePath());
        } catch (Exception e) {
            Log.e(context.getClass().getSimpleName(), "Error Writing Bitmap: ", e);
        } finally {
            if (os != null) {
                os.flush();
                os.close();
            }
        }
        return imageFile;
    }
    public static File getFileFromBitmap(Context context, Bitmap bitmap, String path) throws IOException {
        File imageFile = null;
        File currentFile = new File(path);
        OutputStream os = null;
        try {
            imageFile = new File(currentFile.getParent(), getFileNameWithoutExtension(currentFile) + Constants.EXT_PNG);
            os = new FileOutputStream(imageFile);

            bitmap.compress(Bitmap.CompressFormat.PNG, 70, os);
            Log.v("PATH: ", imageFile.getAbsolutePath());
        } catch (Exception e) {
            Log.e(context.getClass().getSimpleName(), "Error Writing Bitmap: ", e);
        } finally {
            if (os != null) {
                os.flush();
                os.close();
            }
        }
        return imageFile;
    }

    public static Bitmap getBitmapFromFile(File file) {
        Bitmap bitmap = null;
        if (file.exists()) {
            BitmapFactory.Options bmOptions = new BitmapFactory.Options();
            bitmap = BitmapFactory.decodeFile(file.getAbsolutePath(), bmOptions);

        }
        return bitmap;
    }

    public static String getFileName(String path) {
        if (path == null) return null;
        return new File(path).getName();
    }

    public static String getFileNameWithoutExtension(File file) {
        String name = file.getName();
        int pos = name.lastIndexOf('.');
        if (pos > 0 && pos < (name.length() - 1)) {
            return name.substring(0, pos);
        }
        return name;
    }

    /*public static Bitmap drawTextToBitmap(Context context, Bitmap bitmap, String text, int color) {

        // Calculate Width
        TextView textView = new TextView(context);
        textView.setText(text);
        int width = textView.getMeasuredWidth();

        width=25;

        // Get text dimensions
        TextPaint textPaint = new TextPaint(Paint.ANTI_ALIAS_FLAG | Paint.LINEAR_TEXT_FLAG);
        textPaint.setStyle(Paint.Style.FILL);
        textPaint.setColor(Color.parseColor("#ff00ff"));
        textPaint.setTextSize(10);

        StaticLayout mTextLayout = new StaticLayout(text, textPaint, width, Layout.Alignment.ALIGN_CENTER, 1.0f, 0.0f, false);

        // Create bitmap and canvas to draw to
        bitmap = Bitmap.createBitmap(200, mTextLayout.getHeight(), Bitmap.Config.ARGB_4444);
        Canvas c = new Canvas(bitmap);

        // Draw background
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.LINEAR_TEXT_FLAG);
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(color);
        c.drawPaint(paint);

        // Draw text
        c.save();
        c.translate(0, 0);
        mTextLayout.draw(c);
        c.restore();

        return bitmap;
    }

    public static File drawTextToBitmap(Context context, File file, String text, int color) throws FileNotFoundException {
        Bitmap originalBitmap = BitmapFactory.decodeFile(file.getPath());
        originalBitmap = convertToMutable(originalBitmap);
        FileOutputStream out = new FileOutputStream(file);

        try {
            Canvas canvas = new Canvas(originalBitmap);

            Paint paint = new Paint();
            paint.setColor(Color.BLACK);
            paint.setStrokeWidth(12);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_OVER));
            canvas.drawBitmap(originalBitmap, 0, 0, paint);
            canvas.drawText("Testing..shfjkahfkjahjkfhajkhfjkhakjfhjkahjkfhajkfhfj.", 10, 10, paint);

            originalBitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
            out.flush();
            out.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return file;
    }*/
    public static Bitmap convertToMutable(Bitmap imgIn) {
        Log.v("BMP_MUTABLE","TEST");
        try {
            //this is the file going to use temporally to save the bytes.
            // This file will not be a image, it will store the raw image data.
            File file = new File(Environment.getExternalStorageDirectory() + File.separator + "temp.tmp");

            //Open an RandomAccessFile
            //Make sure you have added uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
            //into AndroidManifest.xml file
            RandomAccessFile randomAccessFile = new RandomAccessFile(file, "rw");

            // get the width and height of the source bitmap.
            int width = imgIn.getWidth();
            int height = imgIn.getHeight();
            Bitmap.Config type = imgIn.getConfig();

            //Copy the byte to the file
            //Assume source bitmap loaded using options.inPreferredConfig = Config.ARGB_8888;
            FileChannel channel = randomAccessFile.getChannel();
            MappedByteBuffer map = channel.map(FileChannel.MapMode.READ_WRITE, 0, imgIn.getRowBytes()*height);
            imgIn.copyPixelsToBuffer(map);
            //recycle the source bitmap, this will be no longer used.
            imgIn.recycle();
            System.gc();// try to force the bytes from the imgIn to be released

            //Create a new bitmap to load the bitmap again. Probably the memory will be available.
            imgIn = Bitmap.createBitmap(width, height, type);
            map.position(0);
            //load it back from temporary
            imgIn.copyPixelsFromBuffer(map);
            //close the temporary file and channel , then delete that also
            channel.close();
            randomAccessFile.close();

            // delete the temp file
            file.delete();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return imgIn;
    }

    public static Bitmap drawTextToBitmap(Context mContext, Bitmap bitmap, String mText) {
        try {
            Resources resources = mContext.getResources();
            float scale = resources.getDisplayMetrics().density;
            Bitmap.Config bitmapConfig = bitmap.getConfig();
            if (bitmapConfig == null) {
                bitmapConfig = Bitmap.Config.ARGB_8888;
            }
            // resource bitmaps are imutable,
            // so we need to convert it to mutable one
            bitmap = bitmap.copy(bitmapConfig, true);

            Canvas canvas = new Canvas(bitmap);
            // new antialised Paint
            Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
            // text color - #3D3D3D
            paint.setColor(Color.rgb(0, 0, 0));
            // text size in pixels
            paint.setTextSize((int) (7 * scale));
            //paint.setStyle(Paint.Style.FILL);
            //paint.setStrokeWidth(10);

            // text shadow
            paint.setShadowLayer(1f, 0f, 1f, Color.DKGRAY);

            // draw text to the Canvas center
            Rect bounds = new Rect();
            paint.getTextBounds(mText, 0, mText.length(), bounds);
            int x = 20;
            int y = 20;
            //canvas.drawText(mText, bitmap.getWidth() / 5, y * scale, paint);
            canvas.drawText(mText, x*scale, y * scale, paint);
            return bitmap;
        } catch (Exception e) {
            // TODO: handle exception
            return null;
        }

    }

    public static String saveFileToStorage(String path, Bitmap bitmap) {
        File temp=new File(path);
        try {
            File file=new File(temp.getParent()+"/"+getFileNameWithoutExtension(temp)+"_1"+Constants.PNG);

            try {
                FileOutputStream outStream = new FileOutputStream(file);
                bitmap.compress(Bitmap.CompressFormat.PNG, 45, outStream);
                outStream.flush();
                outStream.close();
                return file.getPath();
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
