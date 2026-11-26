#!/usr/bin/env python3
"""Tạo 4 ảnh danh thiếp mẫu cho assets/danh_thiep/ (CÔNG CỤ TẠM, xoá khi xong dự án).

Cần: Pillow, numpy, opencv-python (dùng cv2.QRCodeEncoder để tạo QR, không cần thư viện qrcode).
Chạy từ thư mục gốc dự án:  python tool/tao_anh_danh_thiep.py [thư_mục_đầu_ra]
Toàn bộ dữ liệu trên ảnh là DỮ LIỆU GIẢ (người, công ty, số điện thoại, email đều hư cấu).
"""
import os
import sys

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else "assets/danh_thiep"
os.makedirs(OUT, exist_ok=True)

FONT_DIRS = ["/usr/share/fonts/opentype/inter/", "/usr/share/fonts/truetype/dejavu/"]


def font(dam, co):
    ten = [("Inter-Bold.otf" if dam else "Inter-Regular.otf"), ("DejaVuSans-Bold.ttf" if dam else "DejaVuSans.ttf")]
    for d in FONT_DIRS:
        for t in ten:
            if os.path.exists(d + t):
                return ImageFont.truetype(d + t, co)
    raise SystemExit("Không tìm thấy font hỗ trợ tiếng Việt (Inter/DejaVu).")


# ---------- Dữ liệu danh thiếp (hư cấu) ----------
THE_1 = {
    "congTy": "CÔNG TY TNHH THƯƠNG MẠI AN PHÁT",
    "hoTen": "NGUYỄN VĂN AN",
    "chucVu": "Giám đốc kinh doanh",
    "dong": [
        "Mobile: 0912 345 678",
        "Tel: 024 3333 4444",
        "Email: an.nguyen@anphat.vn",
        "Web: www.anphat.vn",
        "25 Nguyễn Trãi, Thanh Xuân, Hà Nội",
    ],
    "mau": (22, 60, 110),
}
THE_2 = {
    "congTy": "CÔNG TY CỔ PHẦN GIẢI PHÁP SỐ VIỆT",
    "hoTen": "TRẦN THỊ MINH ANH",
    "chucVu": "Trưởng phòng Marketing",
    "dong": [
        "Mobile: 0987 654 321",
        "Email: minhanh.tran@giaiphapso.vn",
        "Web: www.giaiphapso.vn",
        "88 Lê Lợi, Quận 1, TP. Hồ Chí Minh",
    ],
    "mau": (150, 40, 60),
}
VCARD_QR = (
    "BEGIN:VCARD\r\nVERSION:3.0\r\n"
    "N:Trần;Anh;Thị Minh;;\r\nFN:Trần Thị Minh Anh\r\n"
    "ORG:Công ty Cổ phần Giải pháp Số Việt\r\nTITLE:Trưởng phòng Marketing\r\n"
    "TEL:+84987654321\r\nEMAIL:minhanh.tran@giaiphapso.vn\r\nEND:VCARD"
)
# Cố ý KHÔNG có URL/địa chỉ trong QR: khi quét, ứng dụng lấy từ QR trước rồi dùng OCR điền chỗ trống
# (website, địa chỉ in trên mặt danh thiếp). QR ngắn + mức sửa lỗi L để mỗi ô đủ lớn, đọc chắc sau nén JPEG.

W, H = 1200, 800  # khung ảnh (giống ảnh chụp bàn)
CW, CH = 1000, 600  # kích thước tấm danh thiếp
CX, CY = (W - CW) // 2, (H - CH) // 2


def nen_ban():
    """Mặt bàn gỗ nhạt, có nhiễu nhẹ để ảnh trông như ảnh chụp."""
    rng = np.random.default_rng(7)
    base = np.zeros((H, W, 3), np.float32)
    base[:] = (150, 160, 175)  # RGB nâu xám nhạt
    grad = np.linspace(-18, 18, W, dtype=np.float32)[None, :, None]
    base += grad
    base += rng.normal(0, 4, (H, W, 1)).astype(np.float32)
    return Image.fromarray(np.clip(base, 0, 255).astype(np.uint8))


def them_bong(anh):
    bong = Image.new("L", (W, H), 0)
    ImageDraw.Draw(bong).rectangle([CX + 10, CY + 14, CX + CW + 10, CY + CH + 14], fill=110)
    bong = bong.filter(ImageFilter.GaussianBlur(14))
    den = Image.new("RGB", (W, H), (20, 20, 25))
    anh.paste(den, (0, 0), bong)


def ve_the(the, co_qr=None):
    anh = nen_ban()
    them_bong(anh)
    d = ImageDraw.Draw(anh)
    d.rectangle([CX, CY, CX + CW, CY + CH], fill=(252, 252, 250))
    d.rectangle([CX, CY, CX + 26, CY + CH], fill=the["mau"])  # dải màu bên trái
    x = CX + 70
    rong_chu = CW - 70 - (360 if co_qr else 50)

    def chen_vua(text, dam, co, toi_thieu=22):
        while co > toi_thieu and d.textlength(text, font=font(dam, co)) > rong_chu:
            co -= 1
        return font(dam, co)

    y = CY + 48
    f = chen_vua(the["congTy"], True, 30)
    d.text((x, y), the["congTy"], font=f, fill=the["mau"])
    d.line([x, y + 52, x + rong_chu, y + 52], fill=the["mau"], width=3)
    y += 92
    d.text((x, y), the["hoTen"], font=chen_vua(the["hoTen"], True, 54), fill=(25, 25, 30))
    y += 74
    d.text((x, y), the["chucVu"], font=font(False, 30), fill=(70, 70, 80))
    y += 78
    for dong in the["dong"]:
        d.text((x, y), dong, font=chen_vua(dong, False, 28), fill=(35, 35, 40))
        y += 48
    if co_qr is not None:
        qr = co_qr
        qx, qy = CX + CW - qr.width - 56, CY + CH - qr.height - 64
        d.rectangle([qx - 24, qy - 24, qx + qr.width + 24, qy + qr.height + 24], fill=(255, 255, 255))
        anh.paste(qr, (qx, qy))
    return anh


def tao_qr(noi_dung, canh=300):
    p = cv2.QRCodeEncoder_Params()
    p.correction_level = cv2.QRCodeEncoder_CORRECT_LEVEL_L
    p.mode = cv2.QRCodeEncoder_MODE_BYTE
    ma = cv2.QRCodeEncoder.create(p).encode(noi_dung)
    n = ma.shape[0]
    mod = max(1, canh // n)
    ma = cv2.resize(ma, None, fx=mod, fy=mod, interpolation=cv2.INTER_NEAREST)
    return Image.fromarray(ma).convert("RGB")


def luu_jpeg(anh, ten):
    duong = os.path.join(OUT, ten)
    anh.save(duong, "JPEG", quality=88, optimize=True)
    print("đã tạo", duong, os.path.getsize(duong), "byte")


# 1) Danh thiếp chuẩn
luu_jpeg(ve_the(THE_1), "danh_thiep_1.jpg")

# 2) Danh thiếp có mã QR (vCard)
qr = tao_qr(VCARD_QR)
luu_jpeg(ve_the(THE_2, co_qr=qr), "danh_thiep_2_qr.jpg")

# 3) Ảnh mờ: chụp rung/lấy nét hỏng, không còn đọc được chữ
mo = ve_the(THE_1).filter(ImageFilter.GaussianBlur(26))
mo = Image.blend(mo, Image.new("RGB", mo.size, (170, 170, 170)), 0.25)
luu_jpeg(mo, "danh_thiep_mo.jpg")

# 4) Tệp hỏng: đuôi .jpg nhưng nội dung KHÔNG phải ảnh (để thử đường lỗi "không đọc được ảnh")
with open(os.path.join(OUT, "danh_thiep_hong.jpg"), "wb") as f:
    f.write("Tep nay co duoi .jpg nhung KHONG phai anh - dung de thu duong loi.\n".encode("ascii"))
print("đã tạo", os.path.join(OUT, "danh_thiep_hong.jpg"))

# ---- Tự kiểm tra: QR phải đọc lại đúng; ảnh mờ không được đọc ra QR/chữ ----
doc = cv2.QRCodeDetector()
anh_qr = cv2.imread(os.path.join(OUT, "danh_thiep_2_qr.jpg"))
gia_tri, _, _ = doc.detectAndDecode(anh_qr)
assert gia_tri == VCARD_QR, "QR trong ảnh KHÔNG đọc lại đúng: %r" % gia_tri
print("OK: QR trong danh_thiep_2_qr.jpg đọc lại đúng nội dung vCard")
anh_mo = cv2.imread(os.path.join(OUT, "danh_thiep_mo.jpg"))
assert doc.detectAndDecode(anh_mo)[0] == "", "ảnh mờ lại đọc được QR"
anh_chuan = cv2.imread(os.path.join(OUT, "danh_thiep_1.jpg"))
assert doc.detectAndDecode(anh_chuan)[0] == "", "ảnh chuẩn không được chứa QR"
with open(os.path.join(OUT, "danh_thiep_hong.jpg"), "rb") as f:
    assert f.read(3) != b"\xff\xd8\xff"
print("OK: ảnh chuẩn không có QR, ảnh mờ không đọc được, tệp hỏng không có chữ ký JPEG")