# Phân tích các yếu tố ảnh hưởng đến TDP của vi xử lí Intel

Bài tập lớn môn **Xác suất Thống kê (MT2013)** - Lớp L16 - Nhóm 19
Trường Đại học Bách Khoa - ĐHQG-HCM
Giảng viên hướng dẫn: TS. Hồ Tuấn Đức

## 1. Giới thiệu

Đề tài nghiên cứu mối liên hệ giữa **TDP** (Thermal Design Power - công suất thiết kế nhiệt, đơn vị W) và các thông số kĩ thuật của vi xử lí Intel: số nhân, xung nhịp cơ bản, tiến trình sản xuất, phân khúc thiết bị và tùy chọn nhúng.

Toàn bộ code nằm trong một file duy nhất: `code.R`.

## 2. Dữ liệu

- File: `Intel_CPUs.csv` (Kaggle, tổng hợp từ Intel ARK và Game-Debate)
- Ban đầu: 2.283 quan trắc, 45 cột
- Sau tiền xử lí: **2.159 quan trắc, 6 biến**, không còn giá trị khuyết

| Biến | Loại | Vai trò | Đơn vị |
|---|---|---|---|
| `TDP` | Định lượng | **Y** | W |
| `nb_of_Cores` | Định lượng | X | nhân |
| `Processor_Base_Frequency` | Định lượng | X | GHz |
| `Lithography` | Định lượng | X | nm |
| `Vertical_Segment` | Định tính (Desktop, Mobile, Server, Embedded) | X | - |
| `Embedded_Options_Available` | Định tính (No, Yes) | X | - |

## 3. Yêu cầu

- R (khuyến nghị >= 4.0), chạy được trong RStudio hoặc `Rscript`
- **Không cần cài thêm thư viện**, code chỉ dùng R base

## 4. Cách chạy

1. Đặt file `Intel_CPUs.csv` ở bất kì đâu, mở `code.R`.
2. Sửa đường dẫn ở đầu file:
   ```r
   DATA_PATH <- "/duong/dan/den/Intel_CPUs.csv"
   ```
3. Chạy toàn bộ file (`Ctrl+Shift+S` trong RStudio, hoặc `source("code.R")`).

Bảng và hình được tạo tự động trong thư mục làm việc hiện tại (`bang/` và `hinh/`).

Các tham số có thể chỉnh ở phần cấu hình đầu file:

| Tham số | Mặc định | Ý nghĩa |
|---|---|---|
| `ALPHA` | 0.05 | Mức ý nghĩa của các kiểm định |
| `SEED` | 2026 | Cố định việc chia tập huấn luyện / kiểm tra |
| `TRAIN_PCT` | 0.8 | Tỉ lệ tập huấn luyện (80/20) |

## 5. Cấu trúc code

| Phần | Nội dung | Đầu ra |
|---|---|---|
| 0 | Cấu hình và hàm tiện ích (`show_save`, `save_table`, `with_rn`, `fmt_p`, ...) | - |
| 3 | Tiền xử lí: đọc dữ liệu, lọc biến, xóa dòng khuyết, thống nhất đơn vị (MHz -> GHz), chuyển factor | Dữ liệu sạch `data` |
| 4 | Thống kê mô tả | Bảng 1-10, Hình 1-9 |
| 5.1 | ANOVA một nhân tố (TDP theo phân khúc), kiểm tra giả định (Shapiro-Wilk, Bartlett, Levene), Tukey HSD | Bảng 11-13, Hình 10 |
| 5.2 | Kruskal-Wallis, Wilcoxon từng cặp (hiệu chỉnh Bonferroni) | Bảng 14-15 |
| 5.3 | So sánh TDP theo tùy chọn nhúng (t-test Welch, Wilcoxon) | Bảng 16 |
| 5.4 | Hồi quy tuyến tính bội (mô hình TDP và log(TDP)), VIF, đánh giá MAE / RMSE | Bảng 17-20, Hình 11-13 |

## 6. Đầu ra

Mỗi bảng được lưu thành **PNG** (để chèn báo cáo) và **CSV** cùng tên.

**Thư mục `bang/`**

| Bảng | Nội dung |
|---|---|
| 1-2 | Tần số và tỉ lệ theo phân khúc / tùy chọn nhúng |
| 3-4 | Phân khúc x tùy chọn nhúng (số lượng, tỉ lệ %) |
| 5-6 | Thống kê TDP theo phân khúc / tùy chọn nhúng |
| 7 | Thống kê mô tả các biến định lượng |
| 8-9 | Ma trận tương quan Pearson / Spearman |
| 10 | Trung bình các biến X theo phân khúc |
| 11 | Bảng ANOVA |
| 12 | Kiểm tra giả định ANOVA |
| 13 | Tukey HSD |
| 14-15 | Kruskal-Wallis, Wilcoxon từng cặp |
| 16 | So sánh TDP giữa nhóm No và Yes |
| 17 | Hệ số hồi quy mô hình 1 |
| 18 | Độ phù hợp (R², R² hiệu chỉnh, F) của 2 mô hình |
| 19 | VIF |
| 20 | MAE, RMSE, R² trên tập kiểm tra |

**Thư mục `hinh/`**

| Hình | Nội dung |
|---|---|
| 1-3 | Biến định tính: số CPU theo phân khúc, tùy chọn nhúng, tùy chọn nhúng theo phân khúc |
| 4-5 | Boxplot TDP theo phân khúc / tùy chọn nhúng |
| 6-9 | Phân bố TDP, số nhân, xung nhịp, tiến trình |
| 10 | Q-Q plot phần dư ANOVA |
| 11-12 | Biểu đồ chẩn đoán phần dư mô hình 1 / mô hình 2 |
| 13 | TDP thực tế và TDP dự báo trên tập kiểm tra |

## 7. Lưu ý

- Nếu khung Plots của RStudio quá nhỏ, code chỉ báo thông báo và bỏ qua phần hiển thị; ảnh PNG vẫn được lưu đầy đủ.
- TDP lệch phải mạnh, nên khi giả định chuẩn / đồng nhất phương sai bị vi phạm, kết luận chính nên dựa vào Kruskal-Wallis và Wilcoxon.
- Mô hình log(TDP) được đưa về đơn vị Watt (nhân hệ số hiệu chỉnh) trước khi tính MAE và RMSE để so sánh công bằng với mô hình 1.
- Kết quả hồi quy lặp lại được nhờ `set.seed(SEED)`.

## 8. Thành viên

| STT | Họ và tên | MSSV |
|---|---|---|
| 1 | Lê Quốc Thái | 2313097 |
| 2 | Phạm Ngọc Đức Toàn | 2313496 |
| 3 | Nguyễn Minh Duy | 2513682 |
| 4 | Văn Viết Đức | 2310812 |
| 5 | Nguyễn Đức Duy | 2210510 |