//
// Created by 李鹏辉 on 2020/6/3.
//
#include <jni.h>
#include <string>
#include "libyuv.h"

// nv21 --> i420
void nv21ToI420(jbyte *src_nv21_data, jint width, jint height, jbyte *src_i420_data) {
    jint src_y_size = width * height;
    jint src_u_size = (width >> 1) * (height >> 1);
    jbyte *src_nv21_y_data = src_nv21_data;
    jbyte *src_nv21_vu_data = src_nv21_data + src_y_size;
    jbyte *src_i420_y_data = src_i420_data;
    jbyte *src_i420_u_data = src_i420_data + src_y_size;
    jbyte *src_i420_v_data = src_i420_data + src_y_size + src_u_size;
    libyuv::NV21ToI420((const uint8_t *) src_nv21_y_data, width,
                       (const uint8_t *) src_nv21_vu_data, width,
                       (uint8_t *) src_i420_y_data, width,
                       (uint8_t *) src_i420_u_data, width >> 1,
                       (uint8_t *) src_i420_v_data, width >> 1,
                       width, height);
}

// i420 --> nv12
void i420ToNv12(jbyte *src_i420_data, jint width, jint height, jbyte *src_nv12_data) {
    jint src_y_size = width * height;
    jint src_u_size = (width >> 1) * (height >> 1);
    jbyte *src_nv12_y_data = src_nv12_data;
    jbyte *src_nv12_uv_data = src_nv12_data + src_y_size;
    jbyte *src_i420_y_data = src_i420_data;
    jbyte *src_i420_u_data = src_i420_data + src_y_size;
    jbyte *src_i420_v_data = src_i420_data + src_y_size + src_u_size;
    libyuv::I420ToNV12(
            (const uint8_t *) src_i420_y_data, width,
            (const uint8_t *) src_i420_u_data, width >> 1,
            (const uint8_t *) src_i420_v_data, width >> 1,
            (uint8_t *) src_nv12_y_data, width,
            (uint8_t *) src_nv12_uv_data, width,
            width, height);
}

// 镜像
void mirrorI420(jbyte *src_i420_data, jint width, jint height, jbyte *dst_i420_data) {
    jint src_i420_y_size = width * height;
// jint src_i420_u_size = (width >> 1) * (height >> 1);
    jint src_i420_u_size = src_i420_y_size >> 2;
    jbyte *src_i420_y_data = src_i420_data;
    jbyte *src_i420_u_data = src_i420_data + src_i420_y_size;
    jbyte *src_i420_v_data = src_i420_data + src_i420_y_size + src_i420_u_size;
    jbyte *dst_i420_y_data = dst_i420_data;
    jbyte *dst_i420_u_data = dst_i420_data + src_i420_y_size;
    jbyte *dst_i420_v_data = dst_i420_data + src_i420_y_size + src_i420_u_size;
    libyuv::I420Mirror((const uint8_t *) src_i420_y_data, width,
                       (const uint8_t *) src_i420_u_data, width >> 1,
                       (const uint8_t *) src_i420_v_data, width >> 1,
                       (uint8_t *) dst_i420_y_data, width,
                       (uint8_t *) dst_i420_u_data, width >> 1,
                       (uint8_t *) dst_i420_v_data, width >> 1,
                       width, height);
}

//旋转
void rotateI420(jbyte *src_i420_data, jint width, jint height, jbyte *dst_i420_data, jint degree) {
    jint src_i420_y_size = width * height;
    jint src_i420_u_size = (width >> 1) * (height >> 1);
    jbyte *src_i420_y_data = src_i420_data;
    jbyte *src_i420_u_data = src_i420_data + src_i420_y_size;
    jbyte *src_i420_v_data = src_i420_data + src_i420_y_size + src_i420_u_size;
    jbyte *dst_i420_y_data = dst_i420_data;
    jbyte *dst_i420_u_data = dst_i420_data + src_i420_y_size;
    jbyte *dst_i420_v_data = dst_i420_data + src_i420_y_size + src_i420_u_size;
    if (degree == libyuv::kRotate90 || degree == libyuv::kRotate270) {
        libyuv::I420Rotate((const uint8_t *) src_i420_y_data, width,
                           (const uint8_t *) src_i420_u_data, width >> 1,
                           (const uint8_t *) src_i420_v_data, width >> 1,
                           (uint8_t *) dst_i420_y_data, height,
                           (uint8_t *) dst_i420_u_data, height >> 1,
                           (uint8_t *) dst_i420_v_data, height >> 1,
                           width, height,
                           (libyuv::RotationMode) degree);
    } else {
        libyuv::I420Rotate((const uint8_t *) src_i420_y_data, width,
                           (const uint8_t *) src_i420_u_data, width >> 1,
                           (const uint8_t *) src_i420_v_data, width >> 1,
                           (uint8_t *) dst_i420_y_data, width,
                           (uint8_t *) dst_i420_u_data, width >> 1,
                           (uint8_t *) dst_i420_v_data, width >> 1,
                           width, height,
                           (libyuv::RotationMode) degree);
    }
}


//缩放
void scaleI420(jbyte *src_i420_data, jint width, jint height, jbyte *dst_i420_data, jint dst_width,
               jint dst_height, jint mode) {
    jint src_i420_y_size = width * height;
    jint src_i420_u_size = (width >> 1) * (height >> 1);
    jbyte *src_i420_y_data = src_i420_data;
    jbyte *src_i420_u_data = src_i420_data + src_i420_y_size;
    jbyte *src_i420_v_data = src_i420_data + src_i420_y_size + src_i420_u_size;
    jint dst_i420_y_size = dst_width * dst_height;
    jint dst_i420_u_size = (dst_width >> 1) * (dst_height >> 1);
    jbyte *dst_i420_y_data = dst_i420_data;
    jbyte *dst_i420_u_data = dst_i420_data + dst_i420_y_size;
    jbyte *dst_i420_v_data = dst_i420_data + dst_i420_y_size + dst_i420_u_size;
    libyuv::I420Scale((const uint8_t *) src_i420_y_data, width,
                      (const uint8_t *) src_i420_u_data, width >> 1,
                      (const uint8_t *) src_i420_v_data, width >> 1,
                      width, height,
                      (uint8_t *) dst_i420_y_data, dst_width,
                      (uint8_t *) dst_i420_u_data, dst_width >> 1,
                      (uint8_t *) dst_i420_v_data, dst_width >> 1,
                      dst_width, dst_height,
                      (libyuv::FilterMode) mode);
}

// 裁剪
void cropI420(jbyte *src_i420_data, jint src_length, jint width, jint height,
              jbyte *dst_i420_data, jint dst_width, jint dst_height, jint left, jint top) {
    jint dst_i420_y_size = dst_width * dst_height;
    jint dst_i420_u_size = (dst_width >> 1) * (dst_height >> 1);
    jbyte *dst_i420_y_data = dst_i420_data;
    jbyte *dst_i420_u_data = dst_i420_data + dst_i420_y_size;
    jbyte *dst_i420_v_data = dst_i420_data + dst_i420_y_size + dst_i420_u_size;
    libyuv::ConvertToI420((const uint8_t *) src_i420_data, src_length,
                          (uint8_t *) dst_i420_y_data, dst_width,
                          (uint8_t *) dst_i420_u_data, dst_width >> 1,
                          (uint8_t *) dst_i420_v_data, dst_width >> 1,
                          left, top,
                          width, height,
                          dst_width, dst_height,
                          libyuv::kRotate0, libyuv::FOURCC_I420);
}


extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_compressYUV(JNIEnv *env, jobject thiz,
                                                           jbyteArray src, jint width, jint height,
                                                           jbyteArray dst, jint dst_width,
                                                           jint dst_height,
                                                           jint degree, jboolean isMirror,
                                                           jint mode) {
    jbyte *src_nv21_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_i420_data = env->GetByteArrayElements(dst, NULL);
    jbyte *tmp_dst_i420_data = NULL;
// nv21转换为i420
    jbyte *i420_data = (jbyte *) malloc(sizeof(jbyte) * width * height * 3 / 2);
    nv21ToI420(src_nv21_data, width, height, i420_data);
    tmp_dst_i420_data = i420_data;
// 镜像
    jbyte *i420_mirror_data = NULL;
    if (isMirror) {
        i420_mirror_data = (jbyte *) malloc(sizeof(jbyte) * width * height * 3 / 2);
        mirrorI420(tmp_dst_i420_data, width, height, i420_mirror_data);
        tmp_dst_i420_data = i420_mirror_data;
    }
// 缩放
    jbyte *i420_scale_data = NULL;
    if (width != dst_width || height != dst_height) {
        i420_scale_data = (jbyte *) malloc(sizeof(jbyte) * width * height * 3 / 2);
        scaleI420(tmp_dst_i420_data, width, height, i420_scale_data, dst_width, dst_height, mode);
        tmp_dst_i420_data = i420_scale_data;
        width = dst_width;
        height = dst_height;
    }
// 旋转
    jbyte *i420_rotate_data = NULL;
    if (degree == libyuv::kRotate90 || degree == libyuv::kRotate180 ||
        degree == libyuv::kRotate270) {
        i420_rotate_data = (jbyte *) malloc(sizeof(jbyte) * width * height * 3 / 2);
        rotateI420(tmp_dst_i420_data, width, height, i420_rotate_data, degree);
        tmp_dst_i420_data = i420_rotate_data;
    }
// 同步數據
// memcpy(dst_i420_data, tmp_dst_i420_data, sizeof(jbyte) * width * height * 3 / 2);
    jint len = env->GetArrayLength(dst);
    memcpy(dst_i420_data, tmp_dst_i420_data, len);
    tmp_dst_i420_data = NULL;
    env->ReleaseByteArrayElements(dst, dst_i420_data, 0);
// 釋放
    if (i420_data != NULL) free(i420_data);
    if (i420_mirror_data != NULL) free(i420_mirror_data);
    if (i420_scale_data != NULL) free(i420_scale_data);
    if (i420_rotate_data != NULL) free(i420_rotate_data);

}
extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_cropYUV(JNIEnv *env, jobject thiz, jbyteArray src,
                                                       jint width, jint height, jbyteArray dst,
                                                       jint dst_width, jint dst_height, jint left,
                                                       jint top) {
    //裁剪的區域大小不對
    if (left + dst_width > width || top + dst_height > height) {
        return;
    }
//left和top必須為偶數，否則顯示會有問題
    if (left % 2 != 0 || top % 2 != 0) {
        return;
    }
// i420數據裁剪
    jint src_length = env->GetArrayLength(src);
    jbyte *src_i420_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_i420_data = env->GetByteArrayElements(dst, NULL);
    cropI420(src_i420_data, src_length, width, height, dst_i420_data, dst_width, dst_height, left,
             top);
    env->ReleaseByteArrayElements(dst, dst_i420_data, 0);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_mirrorYUV(JNIEnv *env, jobject thiz, jbyteArray src,
                                                         jint width, jint height, jbyteArray dst) {
    jbyte *src_i420_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_i420_data = env->GetByteArrayElements(dst, NULL);
    // i420數據鏡像
    mirrorI420(src_i420_data, width, height, dst_i420_data);
    env->ReleaseByteArrayElements(dst, dst_i420_data, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_scaleYUV(JNIEnv *env, jobject thiz, jbyteArray src,
                                                        jint width, jint height, jbyteArray dst,
                                                        jint dst_width, jint dst_height,
                                                        jint mode) {
    jbyte *src_i420_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_i420_data = env->GetByteArrayElements(dst, NULL);
// i420數據縮放
    scaleI420(src_i420_data, width, height, dst_i420_data, dst_width, dst_height, mode);
    env->ReleaseByteArrayElements(dst, dst_i420_data, 0);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_rotateYUV(JNIEnv *env, jobject thiz, jbyteArray src,
                                                         jint width, jint height, jbyteArray dst,
                                                         jint degree) {
    jbyte *src_i420_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_i420_data = env->GetByteArrayElements(dst, NULL);
// i420數據旋轉
    rotateI420(src_i420_data, width, height, dst_i420_data, degree);
    env->ReleaseByteArrayElements(dst, dst_i420_data, 0);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_nv21ToYUV(JNIEnv *env, jobject thiz, jbyteArray src,
                                                         jint width, jint height, jbyteArray dst) {
    jbyte *src_nv21_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_i420_data = env->GetByteArrayElements(dst, NULL);
// nv21轉化為i420
    nv21ToI420(src_nv21_data, width, height, dst_i420_data);
    env->ReleaseByteArrayElements(dst, dst_i420_data, 0);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_yUVToNv21(JNIEnv *env, jobject thiz, jbyteArray src,
                                                         jint width, jint height, jbyteArray dst) {
    jbyte *src_i420_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_nv21_data = env->GetByteArrayElements(dst, NULL);
// i420轉化為nv21
    i420ToNv12(src_i420_data, width, height, dst_nv21_data);
    env->ReleaseByteArrayElements(dst, dst_nv21_data, 0);
}extern "C"
JNIEXPORT void JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_yUVToARGB(JNIEnv *env, jobject thiz, jbyteArray src,
                                                         jint width, jint height, jbyteArray dst) {
    jbyte *src_i420_data = env->GetByteArrayElements(src, NULL);
    jbyte *dst_argb_data = env->GetByteArrayElements(dst, NULL);

    libyuv::I420ToARGB((const uint8_t *) src_i420_data, width,
                       (const uint8_t *) (src_i420_data + width * height), width / 2,
                       (const uint8_t *) (src_i420_data + width * height * 5 / 4), width / 2,
                       (uint8_t *) dst_argb_data, width * 4, width,
                       height);
    env->ReleaseByteArrayElements(src, src_i420_data, 0);
    env->ReleaseByteArrayElements(dst, dst_argb_data, 0);

}extern "C"
JNIEXPORT jbyteArray JNICALL
Java_com_rhyme_r_1barcode_utils_RBarcodeNative_yUVFromImage(JNIEnv *env, jobject thiz,
                                                            jbyteArray yb, jbyteArray ub,
                                                            jbyteArray vb, jint y_length,
                                                            jint u_length, jint v_length) {
    jbyte *yb_data = env->GetByteArrayElements(yb,NULL);
    jbyte *ub_data = env->GetByteArrayElements(ub,NULL);
    jbyte *vb_data = env->GetByteArrayElements(vb,NULL);



}