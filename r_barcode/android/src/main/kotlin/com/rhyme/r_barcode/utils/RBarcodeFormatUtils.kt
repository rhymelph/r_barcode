package com.rhyme.r_barcode.utils

import com.google.zxing.BarcodeFormat

object RBarcodeFormatUtils {

    internal fun transitionFromFlutterCode(formats: List<String>): List<BarcodeFormat> {
        val resultFormats = mutableListOf<BarcodeFormat>()

        for (format in formats) {
            resultFormats.add(when (format) {
                "Codabar" -> BarcodeFormat.CODABAR
                "Code39" -> BarcodeFormat.CODE_39
                "Code93" -> BarcodeFormat.CODE_93
                "Code128" -> BarcodeFormat.CODE_128
                "EAN8" -> BarcodeFormat.EAN_8
                "EAN13" -> BarcodeFormat.EAN_13
                "ITF" -> BarcodeFormat.ITF
                "UPCA" -> BarcodeFormat.UPC_A
                "UPCE" -> BarcodeFormat.UPC_E
                //// 2d format
                "Aztec" -> BarcodeFormat.AZTEC
                "DataMatrix" -> BarcodeFormat.DATA_MATRIX
                "PDF417" -> BarcodeFormat.PDF_417
                "QRCode" -> BarcodeFormat.QR_CODE
                else -> throw IllegalArgumentException("not exist value")
            })
        }
        return resultFormats
    }

    internal fun transitionToFlutterCode(barcodeFormat: BarcodeFormat): String {
        return when (barcodeFormat) {
            BarcodeFormat.CODABAR -> "Codabar"
            BarcodeFormat.CODE_39 -> "Code39"
            BarcodeFormat.CODE_93 -> "Code93"
            BarcodeFormat.CODE_128 -> "Code128"
            BarcodeFormat.EAN_8 -> "EAN8"
            BarcodeFormat.EAN_13 -> "EAN13"
            BarcodeFormat.ITF -> "ITF"
            BarcodeFormat.UPC_E -> "UPCE"
            BarcodeFormat.UPC_A -> "UPCA"
            //// 2d format
            BarcodeFormat.AZTEC -> "Aztec"
            BarcodeFormat.DATA_MATRIX -> "DataMatrix"
            BarcodeFormat.PDF_417 -> "PDF417"
            BarcodeFormat.QR_CODE -> "QRCode"
            else -> throw IllegalArgumentException("not exist value")
        }
    }

}