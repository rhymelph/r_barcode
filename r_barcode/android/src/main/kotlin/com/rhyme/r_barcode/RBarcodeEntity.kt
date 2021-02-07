package com.rhyme.r_barcode

data class RBarcodeEntity(val y: ByteArray, val u: ByteArray, val v: ByteArray, val yLen: Int, val uLen: Int, val vLen: Int, val width: Int, val height: Int) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as RBarcodeEntity

        if (!y.contentEquals(other.y)) return false
        if (!u.contentEquals(other.u)) return false
        if (!v.contentEquals(other.v)) return false
        if (yLen != other.yLen) return false
        if (uLen != other.uLen) return false
        if (vLen != other.vLen) return false
        if (width != other.width) return false
        if (height != other.height) return false

        return true
    }

    override fun hashCode(): Int {
        var result = y.contentHashCode()
        result = 31 * result + u.contentHashCode()
        result = 31 * result + v.contentHashCode()
        result = 31 * result + yLen
        result = 31 * result + uLen
        result = 31 * result + vLen
        result = 31 * result + width
        result = 31 * result + height
        return result
    }
}