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

1. Đặt thư mục làm việc là thư mục chứa `code.R`.
2. Sửa đường dẫn ở đầu file cho đúng với máy của bạn:
   ```r
   DATA_PATH <- "/duong/dan/den/Intel_CPUs.csv"
   ```
3. Chạy toàn bộ file (`Ctrl+Shift+S` trong RStudio, hoặc `source("code.R")`).

Bảng và hình được tạo tự động trong thư mục làm việc hiện tại (`bang/` và `hinh/`).

Các tham số có thể chỉnh ở phần cấu hình đầu file:

| Tham số | Mặc định | Ý nghĩa |
|---|---|---|
| `DATA_PATH` | (đường dẫn máy tác giả) | Đường dẫn tới `Intel_CPUs.csv`, **cần sửa** |
| `ALPHA` | 0.05 | Mức ý nghĩa của các kiểm định |
| `SEED` | 2026 | Cố định việc chia tập huấn luyện / kiểm tra |
| `TRAIN_PCT` | 0.8 | Tỉ lệ tập huấn luyện (80/20) |
| `MU0` | 65 | Mốc kiểm định một mẫu: TDP trung bình của Desktop (W) |
| `P0` | 0.5 | Mốc kiểm định tỉ lệ CPU có tùy chọn nhúng |

## 5. Cấu trúc code

| Phần | Nội dung | Đầu ra |
|---|---|---|
| 0 | Cấu hình và hàm tiện ích (`show_save`, `save_table`, `with_rn`, `fmt_p`, `ket_luan`) | - |
| 3 | Tiền xử lí: đọc dữ liệu, lọc 6 biến, xóa dòng khuyết, thống nhất đơn vị (MHz -> GHz), chuyển factor | Dữ liệu sạch `data` |
| 4 | Thống kê mô tả | Bảng 1-10, Hình 1-9 |
| 5.1 | Khoảng tin cậy 95% của TDP theo phân khúc; kiểm định một mẫu (t-test, Wilcoxon cho TDP Desktop; kiểm định tỉ lệ cho tùy chọn nhúng) | Bảng 11-13 |
| 5.2 | Kiểm định hệ số tương quan giữa TDP và từng biến X (Pearson, Spearman) | Bảng 14 |
| 5.3 | ANOVA một nhân tố (TDP theo phân khúc), kiểm tra giả định (Shapiro-Wilk, Bartlett, Levene), Tukey HSD | Bảng 15-17, Hình 10 |
| 5.4 | Kruskal-Wallis (kèm cỡ ảnh hưởng ε²), Wilcoxon từng cặp (hiệu chỉnh Bonferroni) | Bảng 18-19 |
| 5.5 | So sánh TDP theo tùy chọn nhúng (t-test Welch, Wilcoxon) | Bảng 20 |
| 5.6 | Hồi quy tuyến tính bội (mô hình TDP và log(TDP)), VIF, kiểm tra giả định, chọn biến theo AIC, đánh giá MAE / RMSE | Bảng 21-26, Hình 11-13 |

## 6. Đầu ra

Mỗi bảng được lưu thành **PNG** (để chèn báo cáo) và **CSV** cùng tên.

**Thư mục `bang/`** (`bang01` ... `bang26`)

| Bảng | Nội dung |
|---|---|
| 1-2 | Tần số và tỉ lệ theo phân khúc / tùy chọn nhúng |
| 3-4 | Phân khúc x tùy chọn nhúng (số lượng, tỉ lệ %) |
| 5-6 | Thống kê TDP theo phân khúc / tùy chọn nhúng |
| 7 | Thống kê mô tả các biến định lượng |
| 8-9 | Ma trận tương quan Pearson / Spearman |
| 10 | Trung bình các biến X theo phân khúc |
| 11 | Khoảng tin cậy 95% của TDP trung bình theo phân khúc |
| 12 | Kiểm định một mẫu: TDP của Desktop so với mốc `MU0` |
| 13 | Kiểm định tỉ lệ CPU có tùy chọn nhúng |
| 14 | Kiểm định hệ số tương quan giữa TDP và các biến X |
| 15 | Bảng ANOVA |
| 16 | Kiểm tra giả định ANOVA |
| 17 | Tukey HSD |
| 18 | Kruskal-Wallis |
| 19 | Wilcoxon từng cặp (Bonferroni) |
| 20 | So sánh TDP giữa nhóm No và Yes |
| 21 | Hệ số hồi quy mô hình 1 |
| 22 | Độ phù hợp (R², R² hiệu chỉnh, F) của 2 mô hình |
| 23 | VIF (GVIF) của mô hình 1 |
| 24 | Kiểm tra giả định hồi quy (Shapiro-Wilk, Breusch-Pagan, điểm Cook) |
| 25 | Chọn biến theo AIC cho mô hình 2 |
| 26 | MAE, RMSE, R² trên tập kiểm tra |

**Thư mục `hinh/`** (`hinh01_...` ... `hinh13_...`)

| Hình | Nội dung |
|---|---|
| 1-3 | Biến định tính: số CPU theo phân khúc, tùy chọn nhúng, tùy chọn nhúng theo phân khúc |
| 4-5 | Boxplot TDP theo phân khúc / tùy chọn nhúng |
| 6-9 | Phân bố TDP, số nhân, xung nhịp, tiến trình |
| 10 | Q-Q plot phần dư ANOVA |
| 11-12 | Biểu đồ chẩn đoán phần dư mô hình 1 / mô hình 2 |
| 13 | TDP thực tế và TDP dự báo trên tập kiểm tra |

## 7. Kết quả chính

- TDP trung bình theo phân khúc: Server (97,8 W) > Desktop (65,9 W) > Embedded (35,8 W) > Mobile (25,2 W). ANOVA, Kruskal-Wallis và Tukey / Wilcoxon đều cho thấy 6 cặp phân khúc đều khác nhau có ý nghĩa.
- TDP của Desktop không khác mốc 65 W có ý nghĩa (p = 0,4961 với t-test, 0,7256 với Wilcoxon).
- Tỉ lệ CPU có tùy chọn nhúng là 24,8%, khác 50% có ý nghĩa; nhóm có tùy chọn nhúng có TDP thấp hơn nhóm không có.
- TDP tương quan dương với số nhân (r = 0,619) và xung nhịp (r = 0,463); tiến trình có tương quan rất yếu.
- Mô hình 1 (TDP) có R² = 0,7844 (huấn luyện) và R² = 0,7389 (kiểm tra), MAE = 15,73 W, RMSE = 21,51 W; tốt hơn mô hình 2 (log TDP) về dự báo theo Watt.

## 8. Lưu ý

- Nếu khung Plots của RStudio quá nhỏ, code chỉ báo thông báo và bỏ qua phần hiển thị; ảnh PNG vẫn được lưu đầy đủ.
- TDP lệch phải mạnh, giả định chuẩn / đồng nhất phương sai của ANOVA bị vi phạm, nên kết luận chính về so sánh nhóm dựa vào Kruskal-Wallis và Wilcoxon (ANOVA, Tukey chỉ để đối chiếu).
- Các giả định của hồi quy (phần dư chuẩn, phương sai không đổi) cũng bị vi phạm ở cả hai mô hình, nên các p-value của hệ số chỉ mang tính tham khảo.
- Mô hình log(TDP) được đưa về đơn vị Watt (nhân hệ số hiệu chỉnh) trước khi tính MAE và RMSE để so sánh công bằng với mô hình 1.
- Kết quả hồi quy lặp lại được nhờ `set.seed(SEED)`.

## 9. Thành viên

| STT | Họ và tên | MSSV |
|---|---|---|
| 1 | Lê Quốc Thái | 2313097 |
| 2 | Phạm Ngọc Đức Toàn | 2313496 |
| 3 | Nguyễn Minh Duy | 2513682 |
| 4 | Văn Viết Đức | 2310812 |
| 5 | Nguyễn Đức Duy | 2210510 |
