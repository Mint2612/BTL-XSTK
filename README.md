# Phân tích các yếu tố ảnh hưởng đến nhiệt độ của vi xử lý Intel

## 1. Tổng quan dữ liệu

### 1.1 Ngữ cảnh

Nhiệt độ CPU là một chỉ báo quan trọng cho sự ổn định của cả hệ thống máy tính. Nhiệt độ đo trực tiếp phụ thuộc nhiều vào môi trường bên ngoài (nhiệt độ phòng, hệ thống tản nhiệt, tải công việc), nên nghiên cứu này tập trung vào **TDP (Thermal Design Power - Công suất thiết kế nhiệt)**. Đây là thông số định lượng chuẩn hóa do nhà sản xuất công bố, đại diện cho lượng nhiệt tối đa mà CPU tỏa ra khi chạy các tác vụ nặng.

Bộ dữ liệu gồm thông số kĩ thuật của các dòng vi xử lý Intel (nguồn: *Intel_CPUs.csv*, ban đầu gồm 2.283 quan trắc và 45 cột). Nghiên cứu phân tích mối liên hệ giữa TDP với các thông số kĩ thuật cốt lõi: số nhân, xung nhịp cơ bản, tiến trình sản xuất, phân khúc thiết bị và tùy chọn nhúng. Kết quả có ý nghĩa với cả hai nhóm:

- **Kĩ sư, nhà thiết kế phần cứng**: hiểu yếu tố nào quyết định lượng nhiệt của chip.
- **Người dùng**: chọn hệ thống tản nhiệt, bộ nguồn và tối ưu chi phí vận hành (điện năng) phù hợp.

### 1.2 Tổng quan các loại biến

Dựa trên kiến thức cơ sở ngành, các biến được sử dụng gồm:

| STT | Tên biến | Ý nghĩa | Loại biến | Vai trò | Đơn vị / Giá trị |
|---|---|---|---|---|---|
| 1 | `TDP` | Công suất thiết kế nhiệt, lượng nhiệt tối đa CPU tỏa ra | Định lượng | **Y** (biến phụ thuộc) | W |
| 2 | `Vertical_Segment` | Phân khúc sản phẩm | Định tính | X | Desktop (máy bàn), Mobile (thiết bị di động), Server (máy chủ), Embedded (thiết bị nhúng / IoT) |
| 3 | `nb_of_Cores` | Số nhân xử lí | Định lượng | X | nhân |
| 4 | `Processor_Base_Frequency` | Xung nhịp cơ bản | Định lượng | X | GHz |
| 5 | `Embedded_Options_Available` | Có phục vụ tùy chọn nhúng hay không | Định tính | X | Yes / No |
| 6 | `Lithography` | Tiến trình sản xuất | Định lượng | X | nm |

## 2. Kiến thức nền

*(Chưa viết)*

## 3. Tiền xử lí số liệu

Code: đọc dữ liệu bằng `read.csv`, toàn bộ bước tiền xử lí nằm trong file `code.R`.

### 3.1 Đọc dữ liệu và thống nhất giá trị trống

- Đọc file `Intel_CPUs.csv`: **2.283 quan trắc, 45 cột**.
- Các giá trị `"N/A"`, `"NA"` và chuỗi rỗng `""` được thống nhất thành `NA` của R.

### 3.2 Lọc biến

Từ 45 cột, giữ lại 6 cột phục vụ đề tài: `TDP`, `nb_of_Cores`, `Processor_Base_Frequency`, `Vertical_Segment`, `Lithography`, `Embedded_Options_Available`.

### 3.3 Xử lí dữ liệu khuyết

Số giá trị khuyết ở từng biến trước khi xử lí:

| Biến | Số NA |
|---|---|
| `TDP` | 67 |
| `nb_of_Cores` | 0 |
| `Processor_Base_Frequency` | 18 |
| `Vertical_Segment` | 0 |
| `Lithography` | 71 |
| `Embedded_Options_Available` | 1 |

**Cách xử lí: xóa các dòng thiếu dữ liệu** ở `TDP`, `Processor_Base_Frequency`, `Lithography` và `Embedded_Options_Available` bằng `complete.cases()`. Lí do:

- `TDP` là biến phụ thuộc Y nên không điền giá trị ước lượng, vì sẽ làm mối quan hệ giữa X và Y trông mạnh hơn thực tế.
- Số dòng thiếu ở mỗi biến đều nhỏ (khoảng 3% mỗi biến), nên việc xóa ít ảnh hưởng đến mẫu.

Kết quả: còn **2.159 quan trắc** (xóa 124 dòng, khoảng 5,4%, giữ lại 94,6% dữ liệu).

> *Cần kiểm tra:* phân bố 4 phân khúc trước và sau khi xóa có gần như không đổi không (lệch dưới 2-3 điểm phần trăm). Nếu đúng thì mẫu không bị thiên lệch, ghi kết quả vào đây.

### 3.4 Thống nhất đơn vị và chuyển sang dạng số

Dùng biểu đồ "dạng chuỗi" (thay mọi số bằng `#`) để phát hiện các đơn vị khác nhau trong cùng một cột:

| Biến | Dạng ban đầu | Cách xử lí | Kết quả |
|---|---|---|---|
| `Processor_Base_Frequency` | Chuỗi, 2 đơn vị: `# GHz` (đa số) và `# MHz` (107 dòng, CPU đời cũ) | Đổi MHz sang GHz (chia 1000), bỏ đơn vị | Số, đơn vị **GHz** |
| `Lithography` | Chuỗi `# nm` | Bỏ đơn vị `nm` | Số, đơn vị **nm** |
| `TDP` | Chuỗi `# W` | Bỏ đơn vị `W` | Số, đơn vị **W** |
| `nb_of_Cores` | Đã là số | Ép kiểu số | Số, đơn vị nhân |

Việc đổi MHz sang GHz giúp giữ lại toàn bộ 107 CPU đời cũ thay vì xóa. Khi tách số, code lấy **số đầu tiên** trong chuỗi để tránh nối nhầm các chữ số nằm sau đơn vị.

### 3.5 Chuyển biến định tính sang factor

| Biến | Các mức (levels) | Mức mốc |
|---|---|---|
| `Vertical_Segment` | Desktop, Mobile, Server, Embedded | Desktop |
| `Embedded_Options_Available` | No, Yes | No |

### 3.6 Tóm tắt dữ liệu sau tiền xử lí

| Biến | Loại | Vai trò |
|---|---|---|
| `TDP` (W) | Định lượng | Y |
| `nb_of_Cores` | Định lượng | X |
| `Processor_Base_Frequency` (GHz) | Định lượng | X |
| `Lithography` (nm) | Định lượng | X |
| `Vertical_Segment` | Định tính (4 mức) | X |
| `Embedded_Options_Available` | Định tính (2 mức) | X |

Dữ liệu sau xử lí gồm **2.159 quan trắc, 6 biến**, không còn giá trị khuyết.
