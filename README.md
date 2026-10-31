### Phân tích các yếu tố ảnh hưởng đến nhiệt độ của vi xử lý Intel

1. Tổng quan dữ liệu

1.1 Ngữ cảnh:

Nhiệt độ CPU vốn là công cụ đánh giá sự ổn định của cả hệ thống máy tính.

Trong nghiên cứu này, bộ dữ liệu về các dòng vi xử lý Intel được đưa vào phân tích nhằm tìm ra mối liên hệ thực tế giữa các thông số kỹ thuật cốt lõi và mức độ tỏa nhiệt của chip. Thay vì đo lường nhiệt độ trực tiếp vốn phụ thuộc nhiều vào môi trường bên ngoài, nghiên cứu tập trung vào **TDP (Thermal Design Power - Công suất thiết kế nhiệt)**. Đây là thông số định lượng chuẩn hóa do nhà sản xuất quy định, đại diện cho lượng nhiệt tối đa mà CPU tỏa ra khi chạy các tác vụ nặng.

Việc phân tích TDP trong mối tương quan với các yếu tố như số nhân (`nb_of_Cores`), xung nhịp (`Processor_Base_Frequency`), tiến trình sản xuất (`Lithography`), và phân khúc thiết bị (`Vertical_Segment`) sẽ cung cấp một cái nhìn toàn diện: vừa mang ý nghĩa tối ưu hóa kỹ thuật cho các kỹ sư bán dẫn, vừa mang giá trị thực tiễn giúp người dùng đời sống lựa chọn hệ thống tản nhiệt, bộ nguồn và tối ưu chi phí vận hành (hóa đơn tiền điện) một cách khoa học nhất.

1.2 Tổng quan các loại biến

Dựa trên kiến thức cơ sở ngành và khảo sát thị trường tiêu dùng, nhóm nhận thấy 
giá phụ thuộc vào các yếu tố sau:

Biến phụ thuộc Y: giá niêm yiết ( USD ) --> xóa đithành phân pkhúc 
Biến định lượng X: số nhân, xung nhịp cơ bản ( Mhz), bộ nhớ đệm cache (mb)
tiến trình sản xuất (nm)
Biến định tính: phân khúc (destop, mobile, server, embedded) --> làm biến Y, 
không / có hyperthread ( phân luồng ) 

2. kiến thức nền ....

3. 

