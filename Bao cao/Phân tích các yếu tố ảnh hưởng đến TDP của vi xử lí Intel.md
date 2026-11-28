# Phân tích các yếu tố ảnh hưởng đến TDP của vi xử lí Intel

*Báo cáo sơ bộ - Bài tập lớn Xác suất Thống kê (MT2013), Lớp L16, Nhóm 19*

*Giảng viên: TS. Hồ Tuấn Đức. Trường Đại học Bách Khoa - ĐHQG-HCM*

## PHẦN I. GIỚI THIỆU

### Bìa

Gồm hai trang: trang 1 ghi tên đề tài, Khoa, môn học, lớp, nhóm, giảng viên; trang 2 ghi thành viên nhóm.

| STT | Họ và tên | MSSV | Nội dung phụ trách | Tỉ lệ đóng góp |
| --- | --- | --- | --- | --- |
| 1 | Lê Quốc Thái | 2313097 | (điền) | 100% |
| 2 | Phạm Ngọc Đức Toàn | 2313496 | (điền) | 100% |
| 3 | Nguyễn Minh Duy | 2513682 | (điền) | 100% |
| 4 | Văn Viết Đức | 2310812 | (điền) | 100% |
| 5 | Nguyễn Đức Duy | 2210510 | (điền) | 100% |

### Các mục còn lại của Phần I

Lời mở đầu, Tóm tắt, Mục lục, Danh sách bảng, Danh sách hình, Danh sách ký hiệu viết tắt. Đánh số trang i, ii, iii; mục lục và danh sách bảng, hình phải tạo tự động. Các mục này làm sau cùng khi đã chốt nội dung Phần II.

## PHẦN II. NỘI DUNG

## 1. Tổng quan dữ liệu

- **Ngữ cảnh:** TDP (Thermal Design Power, đơn vị W) là công suất nhiệt tối đa mà hệ thống tản nhiệt cần xử lí khi CPU chạy tải thực tế. TDP ảnh hưởng đến thiết kế tản nhiệt, nguồn điện và thời lượng pin, nên việc biết yếu tố nào quyết định TDP là có ích cho thiết kế hệ thống.
- **Nguồn:** file `Intel_CPUs.csv` trên Kaggle, tổng hợp từ Intel ARK và Game-Debate.
- **Quy mô:** ban đầu 2.283 quan trắc, 45 cột; sau tiền xử lí còn 2.159 quan trắc, 6 biến.

| Biến | Loại | Vai trò | Đơn vị |
| --- | --- | --- | --- |
| TDP | Định lượng | Y (phụ thuộc) | W |
| nb\_of\_Cores | Định lượng | X | nhân |
| Processor\_Base\_Frequency | Định lượng | X | GHz |
| Lithography | Định lượng | X | nm |
| Vertical\_Segment | Định tính: Desktop, Mobile, Server, Embedded | X | - |
| Embedded\_Options\_Available | Định tính: No, Yes | X | - |

## 2. Mục tiêu của BTL

Mục tiêu chung: xác định các yếu tố kĩ thuật ảnh hưởng đến TDP và xây dựng mô hình dự báo TDP. Các mục tiêu cụ thể gắn với phương pháp:

| Câu hỏi | Phương pháp |
| --- | --- |
| TDP trung bình mỗi phân khúc là bao nhiêu, ước lượng trong khoảng nào? | Khoảng tin cậy 95% |
| TDP của Desktop có khác 65 W không? Tỉ lệ CPU có tùy chọn nhúng có khác 50% không? | Kiểm định một mẫu (t, Wilcoxon, tỉ lệ) |
| TDP có liên quan đến số nhân, xung nhịp, tiến trình không? | Kiểm định hệ số tương quan |
| TDP có khác nhau giữa 4 phân khúc không? | ANOVA, Tukey; Kruskal-Wallis, Wilcoxon cặp |
| TDP có khác nhau giữa nhóm có và không có tùy chọn nhúng không? | t-test Welch, Wilcoxon |
| Các yếu tố cùng tác động ra sao, dự báo TDP tốt đến đâu? | Hồi quy tuyến tính bội |

## 3. Cơ sở lý thuyết

Mỗi phương pháp tóm tắt theo khung: **mục đích, giả thuyết, thống kê kiểm định, điều kiện áp dụng, quy tắc kết luận**. Mục này cần khoảng 10 trang, nên mỗi phương pháp nên có công thức chính và một ví dụ ngắn.

1. **Thống kê mô tả:** trung bình, trung vị, độ lệch chuẩn, tứ phân vị, hệ số bất đối xứng, hệ số tương quan Pearson và Spearman.
2. **Khoảng tin cậy và kiểm định một mẫu:** t-test một mẫu (điều kiện: chuẩn hoặc n lớn), Wilcoxon signed-rank (phi tham số), kiểm định tỉ lệ.
3. **Kiểm định hệ số tương quan:** H0: hệ số tương quan = 0, thống kê t.
4. **ANOVA một nhân tố:** H0: các trung bình bằng nhau, thống kê F = MSB/MSW. Giả định: phần dư chuẩn (Shapiro-Wilk), phương sai đồng nhất (Bartlett, Levene). So sánh bội bằng Tukey HSD.
5. **Kruskal-Wallis và Wilcoxon cặp (Bonferroni):** phương án phi tham số khi ANOVA vi phạm giả định; cỡ ảnh hưởng ε².
6. **So sánh hai mẫu độc lập:** t-test Welch, Wilcoxon rank-sum.
7. **Hồi quy tuyến tính bội:** mô hình Y = b0 + b1X1 + ... + e, ước lượng bình phương nhỏ nhất, R² và R² hiệu chỉnh, kiểm định F, kiểm định t cho hệ số, biến giả cho biến định tính, VIF/GVIF, giả định phần dư (chuẩn, phương sai không đổi, điểm ảnh hưởng Cook), chọn biến theo AIC, đánh giá bằng MAE và RMSE trên tập kiểm tra.

## 4. Tiền xử lí số liệu

1. Đọc dữ liệu, thống nhất các giá trị trống ("N/A", "NA", "") thành NA.
2. Giữ lại 6 biến phục vụ đề tài (từ 45 cột).
3. Xử lí dữ liệu khuyết: xóa các dòng thiếu ở bất kì biến nào, còn 2.159 quan trắc.
4. Thống nhất đơn vị: xung nhịp có cả MHz và GHz, đổi MHz sang GHz; tách phần số khỏi đơn vị cho TDP, Lithography.
5. Chuyển Vertical\_Segment (mức mốc Desktop) và Embedded\_Options\_Available (mức mốc No) sang factor.
6. Kiểm tra lại cấu trúc: 2.159 quan trắc, 6 biến, không còn NA.
7. Chia tập huấn luyện / kiểm tra 80/20 (seed = 2026) cho phần hồi quy.

*(Chèn ảnh code phần này vào phụ lục.)*

## 5. Thống kê mô tả

Chèn Bảng 1-10 và Hình 1-9, mỗi bảng hoặc hình kèm một đoạn nhận xét. Nhận xét chính:

**Biến định tính (Bảng 1-4, Hình 1-3)**

- Server (32,8%) và Mobile (31,9%) chiếm nhiều nhất, tiếp theo là Desktop (27,5%) và Embedded (7,8%).
- 75,2% CPU không có tùy chọn nhúng. Phân khúc Embedded có tới 95,2% CPU có tùy chọn nhúng, trong khi các phân khúc còn lại chỉ khoảng 18-22%. Hai biến định tính này liên quan chặt với nhau, cần lưu ý khi hồi quy.

**TDP theo nhóm (Bảng 5-6, Hình 4-5)**

| Phân khúc | n | Trung bình (W) | Trung vị (W) | Độ lệch chuẩn |
| --- | --- | --- | --- | --- |
| Desktop | 593 | 65,9 | 65 | 30,7 |
| Mobile | 689 | 25,2 | 25 | 15,0 |
| Server | 709 | 97,8 | 95 | 46,6 |
| Embedded | 168 | 35,8 | 35 | 26,1 |

- Server cao nhất, Mobile thấp nhất; độ phân tán của Server lớn nhất.
- Nhóm có tùy chọn nhúng có TDP trung bình 44,1 W, thấp hơn nhóm không có (66,6 W).

**Biến định lượng (Bảng 7-10, Hình 6-9)**

- TDP có trung bình 61,03 W, trung vị 51 W, hệ số bất đối xứng 1,13 (lệch phải). Số nhân lệch phải rất mạnh (6,35); tiến trình lệch phải (1,93); xung nhịp gần đối xứng (-0,16).
- Tương quan Pearson với TDP: số nhân 0,619; xung nhịp 0,463; tiến trình -0,118. Spearman: 0,502; 0,593; -0,035.
- Server có số nhân trung bình cao nhất (7,8); Desktop có xung nhịp cao nhất (2,68 GHz); Embedded có tiến trình nhỏ nhất (25,3 nm).

## 6. Thống kê suy diễn

Mỗi phương pháp trình bày theo khung: **mục tiêu, giả thuyết, kết quả, nhận xét, kết luận**. Mức ý nghĩa α = 0,05.

### 6.1. Khoảng tin cậy và kiểm định một mẫu (Bảng 11-13)

- **Mục tiêu:** ước lượng TDP trung bình từng phân khúc; kiểm tra TDP Desktop có bằng 65 W không; kiểm tra tỉ lệ CPU có tùy chọn nhúng có bằng 50% không.
- **Kết quả:** khoảng tin cậy 95% của TDP trung bình là Desktop \[63,38; 68,34\], Mobile \[24,05; 26,29\], Server \[94,37; 101,24\], Embedded \[31,87; 39,83\].
- **Kiểm định TDP Desktop (H0: μ = 65):** t = 0,68, p = 0,4961; Wilcoxon p = 0,7256. Không bác bỏ H0.
- **Kiểm định tỉ lệ (H0: p = 0,5):** tỉ lệ mẫu 0,2483, khoảng tin cậy \[0,2303; 0,2672\], p < 0,001. Bác bỏ H0.
- **Kết luận:** chưa đủ bằng chứng để nói TDP trung bình của Desktop khác 65 W; tỉ lệ CPU có tùy chọn nhúng thấp hơn 50% có ý nghĩa thống kê.

### 6.2. Kiểm định hệ số tương quan (Bảng 14)

- **Giả thuyết:** H0: hệ số tương quan giữa TDP và biến X bằng 0.
- **Kết quả:** số nhân (r = 0,619; p < 0,001), xung nhịp (r = 0,463; p < 0,001), tiến trình (r = -0,118; p < 0,001). Với Spearman, tiến trình có rho = -0,035, p = 0,1043.
- **Nhận xét:** số nhân và xung nhịp có tương quan dương có ý nghĩa. Tiến trình chỉ có tương quan rất yếu và không nhất quán giữa hai loại hệ số.
- **Kết luận:** TDP tăng theo số nhân và xung nhịp; tiến trình có liên hệ tuyến tính yếu với TDP.

### 6.3. ANOVA một nhân tố: TDP theo phân khúc (Bảng 15-17, Hình 10)

- **Giả thuyết:** H0: TDP trung bình của 4 phân khúc bằng nhau; H1: có ít nhất một cặp khác nhau.
- **Kết quả:** F = 597,19 (bậc tự do 3 và 2155), p < 0,001. Bác bỏ H0.
- **Kiểm tra giả định:** Shapiro-Wilk (W = 0,9447), Bartlett (K² = 775,76) và Levene (F = 130,73) đều có p < 0,001, tức phần dư không chuẩn và phương sai không đồng nhất.
- **Tukey HSD:** cả 6 cặp phân khúc khác nhau có ý nghĩa. Chênh lệch lớn nhất là Server so với Mobile (+72,63 W); nhỏ nhất là Embedded so với Mobile (+10,67 W, p = 0,0011).
- **Kết luận:** TDP phụ thuộc phân khúc. Do giả định bị vi phạm, kết quả ANOVA chỉ dùng để đối chiếu với phương pháp phi tham số ở mục 6.4.

### 6.4. Kruskal-Wallis và Wilcoxon từng cặp (Bảng 18-19)

- **Giả thuyết:** H0: phân phối TDP của 4 phân khúc như nhau.
- **Kết quả:** H = 1084,7 (bậc tự do 3), p < 0,001, cỡ ảnh hưởng ε² = 0,503 (lớn). Wilcoxon từng cặp (Bonferroni): cả 6 cặp có p < 0,001.
- **Kết luận:** phân khúc ảnh hưởng mạnh và có ý nghĩa đến TDP; kết quả phi tham số nhất quán với ANOVA, nên kết luận đáng tin cậy.

### 6.5. So sánh TDP theo tùy chọn nhúng (Bảng 20)

- **Giả thuyết:** H0: TDP của nhóm No và Yes như nhau.
- **Kết quả:** t-test Welch t = 12,58 (bậc tự do 1375), p < 0,001; Wilcoxon W = 557488, p < 0,001.
- **Kết luận:** CPU có tùy chọn nhúng có TDP thấp hơn có ý nghĩa thống kê.
- **Lưu ý:** khác biệt này có thể một phần do cấu trúc phân khúc (Embedded gần như toàn bộ có tùy chọn nhúng). Hồi quy bội ở mục 6.6 giúp tách riêng ảnh hưởng.

### 6.6. Hồi quy tuyến tính bội (Bảng 21-26, Hình 11-13)

- **Mục tiêu:** đo ảnh hưởng đồng thời của các yếu tố đến TDP và dự báo TDP.
- **Mô hình 1:** TDP \~ nb\_of\_Cores + Processor\_Base\_Frequency + Lithography + Vertical\_Segment + Embedded\_Options\_Available, ước lượng trên tập huấn luyện 80%. **Mô hình 2:** thay biến phụ thuộc bằng log(TDP).

**Hệ số mô hình 1 (Bảng 21)**

| Hệ số | Ước lượng | p-value |
| --- | --- | --- |
| Hằng số | -30,113 | < 0,001 |
| Số nhân | 3,894 | < 0,001 |
| Xung nhịp (GHz) | 27,626 | < 0,001 |
| Tiến trình (nm) | 0,245 | < 0,001 |
| Mobile (so với Desktop) | -15,644 | < 0,001 |
| Server (so với Desktop) | 21,848 | < 0,001 |
| Embedded (so với Desktop) | 0,846 | 0,7348 |
| Có tùy chọn nhúng | -8,978 | < 0,001 |

- **Diễn giải:** giữ các yếu tố khác không đổi, thêm 1 nhân làm TDP tăng khoảng 3,9 W; tăng 1 GHz xung nhịp làm TDP tăng khoảng 27,6 W; tiến trình lớn hơn (công nghệ cũ hơn) có TDP cao hơn; Mobile thấp hơn Desktop khoảng 15,6 W, Server cao hơn khoảng 21,8 W; Embedded không khác Desktop có ý nghĩa; có tùy chọn nhúng thấp hơn khoảng 9 W.
- **Độ phù hợp (Bảng 22):** mô hình 1 có R² = 0,7844, R² hiệu chỉnh = 0,7835, F = 893,4, p < 0,001. Mô hình 2 có R² = 0,7267, R² hiệu chỉnh = 0,7256.
- **Đa cộng tuyến (Bảng 23):** GVIF hiệu chỉnh của mọi biến từ 1,15 đến 1,32, ở mức thấp.
- **Giả định (Bảng 24, Hình 11-12):** Shapiro-Wilk và Breusch-Pagan đều có p < 0,001 ở cả hai mô hình, tức phần dư không chuẩn và phương sai thay đổi; có 74 điểm Cook > 4/n ở mô hình 1 và 118 điểm ở mô hình 2.
- **Chọn biến AIC (Bảng 25):** giữ lại cả 5 biến, AIC không đổi (2424,9).
- **Dự báo trên tập kiểm tra (Bảng 26, Hình 13):**

| Mô hình | MAE (W) | RMSE (W) | R² kiểm tra |
| --- | --- | --- | --- |
| Mô hình 1: TDP | 15,73 | 21,51 | 0,7389 |
| Mô hình 2: log(TDP) | 19,38 | 32,68 | 0,3970 |

- **Kết luận:** mô hình 1 giải thích khoảng 78% biến thiên của TDP và dự báo tốt hơn mô hình 2 theo đơn vị Watt (sai số trung bình khoảng 15,7 W). Số nhân, xung nhịp, tiến trình, phân khúc (Mobile, Server) và tùy chọn nhúng đều ảnh hưởng có ý nghĩa đến TDP. Tuy vậy, giả định hồi quy bị vi phạm nên p-value của hệ số chỉ mang tính tham khảo.

## 7. Kết luận tổng hợp, thảo luận và mở rộng

**Tổng hợp**

- Phân khúc là yếu tố phân biệt TDP rõ nhất: Server > Desktop > Embedded > Mobile, mọi cặp đều khác nhau có ý nghĩa.
- Số nhân và xung nhịp làm tăng TDP; mô hình hồi quy bội giải thích khoảng 78% biến thiên của TDP.
- Mô hình 1 (TDP) dự báo trên tập kiểm tra tốt hơn mô hình log(TDP) (RMSE 21,51 W so với 32,68 W).

**Ưu điểm**

- Kết hợp cả phương pháp tham số và phi tham số, kết quả nhất quán với nhau.
- Có kiểm tra giả định ở từng bước và đánh giá dự báo trên tập kiểm tra độc lập.
- Code chỉ dùng R base, chạy lại được nhờ cố định seed.

**Hạn chế**

- TDP lệch phải; giả định chuẩn và phương sai đồng nhất của ANOVA và hồi quy bị vi phạm.
- Dữ liệu là danh mục sản phẩm, không phải mẫu ngẫu nhiên; các CPU cùng dòng có thể không độc lập.
- Xóa các dòng khuyết làm mất khoảng 124 quan trắc (2.283 xuống 2.159), có thể gây lệch chọn.
- Phân khúc Embedded và tùy chọn nhúng liên quan chặt, khó tách riêng ảnh hưởng.
- Mô hình log(TDP) dự báo kém sau khi đổi về Watt.

**Đề nghị mở rộng**

- Thêm các biến như cache, số luồng, bộ nhớ tối đa; xét thêm tương tác (ví dụ số nhân x xung nhịp).
- Thử các phép biến đổi khác (căn bậc hai, Box-Cox), hồi quy ổn định (robust) hoặc mô hình tổng quát hóa.
- ANOVA hai nhân tố (phân khúc x tùy chọn nhúng).

## 8. Tài liệu tham khảo

*(Điền: giáo trình Xác suất Thống kê của trường, tài liệu R, trang dữ liệu Kaggle và Intel ARK.)*

## 9. Phụ lục

- Nguồn dữ liệu: link Kaggle của `Intel_CPUs.csv` (điền link).
- Source code: link GitHub chứa `code.R` (điền link).
- Hình ảnh minh họa code (không giới hạn trang).
