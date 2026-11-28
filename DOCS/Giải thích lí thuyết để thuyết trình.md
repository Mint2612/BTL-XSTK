# Giải thích lí thuyết để thuyết trình

*BTL Xác suất Thống kê, Nhóm 19: Các yếu tố ảnh hưởng đến TDP của vi xử lí Intel*

Mỗi phần theo cùng một khung: **hình dung đời thường → cách hoạt động → áp vào bài của nhóm → lưu ý khi thầy hỏi**. Số liệu lấy từ báo cáo bản mới nhất.

## 0. Câu chuyện xuyên suốt (nói ở slide mở đầu)

**TDP giống "độ nóng" của một cái bếp.** Bếp gas mini cho một người thì nóng ít; bếp công nghiệp của nhà hàng thì nóng nhiều. CPU cũng vậy: chip trong điện thoại tỏa ít nhiệt, chip trong máy chủ tỏa rất nhiều nhiệt. TDP (đơn vị W) chính là con số nhà sản xuất công bố để nói "hệ thống tản nhiệt phải chịu được chừng đó nhiệt".

Câu hỏi của nhóm: **cái gì làm một con chip "nóng" hơn con chip khác?** Có 5 nghi phạm: số nhân, xung nhịp, tiến trình sản xuất, phân khúc (Desktop, Mobile, Server, Embedded) và tùy chọn nhúng. Thống kê là công cụ để "điều tra": nghi phạm nào thật sự có tội, tội nặng đến đâu, và có dự đoán được độ nóng không.

**Một câu tóm cả bài:** *"Chúng em dùng dữ liệu của 2.159 con chip để tìm ra yếu tố nào quyết định độ nóng của chip, và xây một công thức dự đoán độ nóng đó."*

## 1. Ba ý tưởng nền (hiểu ba ý này là hiểu 80% bài)

### 1.1. Mẫu và tổng thể

**Hình dung:** nếm một thìa canh để biết cả nồi có vừa miệng không. Cái thìa là **mẫu**, cả nồi là **tổng thể**. Thống kê suy diễn là nghệ thuật nói về cả nồi chỉ dựa vào một thìa, kèm theo lời cảnh báo "có thể sai bao nhiêu".

### 1.2. Kiểm định giả thuyết = phiên tòa

- **H₀ (giả thuyết không)** = "bị cáo vô tội": không có gì đặc biệt, không có khác biệt, không có quan hệ.
- **H₁ (đối thuyết)** = "bị cáo có tội": có khác biệt.
- **Dữ liệu** = bằng chứng tại tòa.
- **p-value** = *"nếu bị cáo thật sự vô tội, thì khả năng ta thấy bằng chứng lạ thế này là bao nhiêu?"* p càng nhỏ, bằng chứng càng khó giải thích bằng sự trùng hợp.
- **Mức ý nghĩa α = 0,05** = ngưỡng "nghi ngờ hợp lí" mà ta đặt trước: nếu p < 0,05 thì **bác bỏ H₀** (kết tội).
- **Sai lầm loại I** = kết án nhầm người vô tội. α chính là xác suất ta chấp nhận để mắc sai lầm này (5%).

**Câu thầy hay hỏi:** *"Sao không viết 'chấp nhận H₀'?"* → Tòa chỉ có hai phán quyết thực tế: "đủ bằng chứng để kết tội" hoặc "chưa đủ bằng chứng". Chưa đủ bằng chứng **không** chứng minh được vô tội. Vì vậy ta viết *"không bác bỏ H₀"*, như ở phần Desktop 65 W.

### 1.3. Tham số và phi tham số

- **Phương pháp tham số** (t-test, ANOVA, hồi quy) giống **cân bằng cân điện tử**: chính xác, nhưng đòi hỏi điều kiện (dữ liệu có hình chuông, độ phân tán đều).
- **Phương pháp phi tham số** (Wilcoxon, Kruskal-Wallis, Spearman) giống **xếp hạng cuộc thi chạy**: không cần biết ai chạy bao nhiêu giây, chỉ cần biết ai nhất, nhì, ba. Ít đòi hỏi, ít bị ngoại lai làm lệch, nhưng hơi "thô" hơn.

Bài của nhóm dùng **cả hai song song** để kiểm tra chéo: nếu hai cách cho cùng kết luận thì kết luận đáng tin.

## 2. Thống kê mô tả

### 2.1. Trung bình, trung vị, độ lệch

**Hình dung:** 9 người trong quán cà phê lương 10 triệu, rồi một tỉ phú bước vào. **Trung bình** lương cả quán vọt lên rất cao, nhưng **trung vị** (người đứng giữa hàng) vẫn là 10 triệu. Trung bình "bị kéo" bởi người cực đoan, trung vị thì không.

- **Độ lệch chuẩn** = mọi người cách mức trung bình "trung bình" bao xa (đo độ "loe" của dữ liệu).
- **Hệ số bất đối xứng > 0** = "đuôi dài bên phải": đa số bình thường, một số ít cực lớn.

**Trong bài:** TDP có trung bình 61,03 W lớn hơn trung vị 51 W, bất đối xứng 1,13 → đa số chip "vừa phải", vài chip rất nóng (đến 300 W, máy chủ). Số nhân lệch còn dữ hơn (6,35): trung vị 2 nhân nhưng có chip 72 nhân. **Đây là lí do ta phải cẩn thận với các giả định ở phần sau.**

### 2.2. Boxplot

**Hình dung:** cái hộp chứa 50% dữ liệu ở giữa, vạch trong hộp là trung vị, chấm lẻ loi ngoài "râu" là ngoại lai. Hộp càng dài = nhóm càng phân tán. Trong bài: hộp của Server dài nhất, hộp của Mobile ngắn nhất.

### 2.3. Tương quan Pearson và Spearman

**Hình dung:** chiều cao và cân nặng của học sinh: người cao thường nặng hơn, tạo thành một dải chéo đi lên. Hệ số **r** là con số từ −1 đến 1 đo "dải đó chặt và chéo cỡ nào".

- r gần 1: cùng tăng; gần −1: một tăng một giảm; gần 0: không thấy quan hệ **đường thẳng**.
- **Pearson** đo quan hệ theo "đường thẳng" và dùng số liệu thật. **Spearman** chỉ dùng **thứ hạng** (ai cao thứ mấy, ai nặng thứ mấy), nên miễn nhiễm với ngoại lai.
- **Cảnh báo quan trọng:** tương quan **không** phải nhân quả. Bán kem nhiều và chết đuối nhiều cùng tăng vào mùa hè, nhưng kem không gây chết đuối.

**Trong bài:** TDP với số nhân r = 0,619; với xung nhịp 0,463; với tiến trình −0,118 (rất yếu). Số nhân và tiến trình có Spearman −0,667: chip đời mới (tiến trình nhỏ) thường có nhiều nhân hơn.

## 3. Khoảng tin cậy

**Hình dung: ném lưới bắt cá.** Ta không biết chính xác con cá (giá trị thật của tổng thể) nằm đâu, nên thay vì chỉ một mũi lao (một con số), ta ném cả cái lưới (một khoảng). Với độ tin cậy 95%: *nếu lặp lại quy trình lấy mẫu rất nhiều lần, khoảng 95% số lưới sẽ chụp trúng con cá.*

- Lưới **hẹp** khi mẫu lớn và dữ liệu ít loe; **rộng** khi mẫu nhỏ hoặc dữ liệu loe nhiều.
- Công thức đọc thành lời: *"trung bình mẫu ± (hệ số) × (độ loe chia căn bậc hai cỡ mẫu)"*. Mẫu lớn gấp 4 thì lưới hẹp đi một nửa.
- **Lưu ý:** không nói "có 95% xác suất giá trị thật nằm trong khoảng này" (giá trị thật cố định, chỉ có cái lưới là ngẫu nhiên).

**Trong bài:** TDP trung bình của Desktop nằm trong \[63,38; 68,34\] W; Embedded rộng nhất \[31,87; 39,83\] vì chỉ có 168 chip. Bốn lưới **không chồng lên nhau** → gợi ý 4 phân khúc thật sự khác nhau (sau đó kiểm định chính thức).

## 4. Kiểm định một mẫu

### 4.1. t-test: "tín hiệu so với tiếng ồn"

**Hình dung:** nghe radio. **Tín hiệu** = chênh lệch giữa điều ta thấy và điều ta giả sử (trung bình mẫu so với mốc). **Tiếng ồn** = mức dao động bình thường của trung bình mẫu. Thống kê t = tín hiệu ÷ tiếng ồn. t lớn → tín hiệu át tiếng ồn → khó là trùng hợp.

**Trong bài (Desktop so với 65 W):** trung bình mẫu 65,86 W, chênh 0,86 W; tiếng ồn khoảng 1,26 W (30,7/√593). t = 0,68, tức chênh lệch chỉ bằng chưa tới một "nhịp rung" bình thường → p = 0,4961 → **không bác bỏ H₀**. Hiểu nôm na: 65,86 so với 65 chỉ là chênh lệch do may rủi lấy mẫu.

### 4.2. Wilcoxon signed-rank: bản "xếp hạng"

Thay vì dùng giá trị thật, xếp hạng độ lệch của từng chip so với mốc 65 W rồi xem bên trên hay bên dưới có "trọng lượng" hơn. Ưu điểm: không cần dữ liệu hình chuông. Trong bài: p = 0,7256, cùng kết luận → kết quả vững.

### 4.3. Kiểm định tỉ lệ: "đồng xu có công bằng không?"

**Hình dung:** tung đồng xu 2.159 lần, ra 536 mặt "Yes" (24,8%). Đồng xu công bằng sẽ cho khoảng 50%. Sai số bình thường của tỉ lệ ở cỡ mẫu này chỉ khoảng 1,1 điểm phần trăm, nên 24,8% cách 50% tới hơn 23 "đơn vị sai số" → p < 0,001 → **bác bỏ**: đồng xu thiên vị, chỉ khoảng một phần tư chip có tùy chọn nhúng.

## 5. Kiểm định hệ số tương quan

Phiên tòa: **H₀: giữa hai biến không có quan hệ (ρ = 0)**. Dữ liệu cho r = 0,619 → p < 0,001 → bác bỏ H₀ → quan hệ có thật.

**Chi tiết rất dễ ăn điểm:** tiến trình có Pearson r = −0,118 với p < 0,001 ("có ý nghĩa") nhưng Spearman p = 0,1043 ("không có ý nghĩa"). Giải thích: **"có ý nghĩa thống kê" khác "quan trọng"**. Mẫu rất lớn (2.159) giống kính hiển vi cực mạnh: thấy được cả vết bụi. Vết bụi có thật nhưng không đáng kể. Vì vậy ta nhìn cả **độ lớn của r**, không chỉ p.

## 6. So sánh hai nhóm: No và Yes

**Hình dung:** so điểm trung bình lớp A và lớp B. Hai lớp có thể đồng đều khác nhau, nên cần cách so sánh **không giả sử độ phân tán hai lớp bằng nhau** → đó là **t-test Welch** (nhóm No có độ lệch chuẩn 47,1; nhóm Yes chỉ 31,4). **Wilcoxon rank-sum** là bản xếp hạng tương ứng.

**Trong bài:** chênh khoảng 22,5 W (66,6 so với 44,1), t = 12,58, p < 0,001 → bác bỏ.

**Lưu ý thầy chắc chắn để ý:** nhóm Yes "nhẹ" hơn phần lớn vì **95,2% chip Embedded có tùy chọn nhúng**, mà Embedded vốn nguội. Giống kết luận "người mang ô thì hay ướt" khi thật ra do trời mưa. Đây là **biến gây nhiễu** (confounder), và hồi quy bội sẽ gỡ nó ra.

## 7. ANOVA một nhân tố

### 7.1. Ý tưởng cốt lõi

**Hình dung:** 4 lớp học thi chung một đề. Có hai nguồn chênh điểm:

- **Giữa các lớp:** điểm trung bình lớp này khác lớp kia.
- **Trong nội bộ lớp:** học sinh cùng lớp vẫn chênh nhau (đây là "tiếng ồn" bình thường).

Nếu chênh lệch **giữa** các lớp to hơn nhiều so với chênh lệch **trong** lớp, thì "lớp học" (ở đây là phân khúc) thật sự có tác động. Thống kê **F = (biến thiên giữa nhóm) ÷ (biến thiên trong nhóm)**. F ≈ 1 nghĩa là không có gì đặc biệt.

**Trong bài:** F = 597,19, tức chênh lệch giữa phân khúc lớn gấp gần 600 lần mức "tiếng ồn" nội bộ → p < 0,001. Cỡ ảnh hưởng **η² ≈ 0,454**: phân khúc một mình giải thích khoảng **45%** sự khác nhau về TDP.

### 7.2. Vì sao không so từng cặp bằng t-test?

4 nhóm có 6 cặp. Mỗi lần kiểm định chấp nhận 5% rủi ro kết án nhầm; làm 6 lần thì rủi ro cộng dồn lên khoảng **26%** (1 − 0,95⁶). Giống chơi xổ số nhiều vé: vé nào cũng có cơ may trúng nhỏ, nhưng nhiều vé thì dễ có một vé trúng "do tình cờ". ANOVA kiểm tra **một lần cho cả nhóm**.

### 7.3. Tukey HSD: sau khi biết "có khác", hỏi "ai khác ai"

Tukey so tất cả các cặp nhưng **siết ngưỡng lại** để rủi ro tổng vẫn giữ ở 5%. Trong bài, cả 6 cặp đều khác; cặp gần nhau nhất là Embedded và Mobile (chênh 10,67 W, p = 0,0011).

### 7.4. Ba điều kiện của ANOVA và vì sao bài vi phạm

| Điều kiện | Hình dung | Kết quả trong bài |
| --- | --- | --- |
| Phần dư có hình chuông | Sai số dự đoán đối xứng | Vi phạm (Shapiro-Wilk p < 0,001) |
| Độ phân tán các nhóm bằng nhau | Các lớp "loe" như nhau | Vi phạm (Bartlett, Levene p < 0,001) |
| Quan sát độc lập | Mỗi chip một "phiếu bầu" riêng | Giả định theo cách thu thập |

Không giấu điều này, mà **chủ động nói**: vì vi phạm nên nhóm kiểm tra chéo bằng Kruskal-Wallis (mục sau). Thêm một lí lẽ: mẫu lớn (2.159) nên ANOVA tương đối chịu được vi phạm nhẹ, và chênh lệch rất lớn (F gần 600) khó bị đảo ngược bởi vi phạm nhẹ.

## 8. Kruskal-Wallis và Wilcoxon từng cặp

**Hình dung:** xếp **toàn bộ 2.159 chip thành một hàng** từ nóng ít đến nóng nhiều, gán hạng 1, 2, 3... Rồi hỏi: "hạng trung bình của 4 phân khúc có khác nhau không?" Nếu phân khúc không quan trọng, hạng sẽ trộn đều; thực tế Mobile dồn ở đầu hàng, Server dồn ở cuối hàng.

- Không cần hình chuông, không cần độ loe bằng nhau, ít bị ngoại lai làm nhiễu.
- **Bonferroni:** muốn so từng cặp mà vẫn an toàn thì "nhân p lên số cặp" (6 cặp thì nhân 6), tức khó kết tội hơn để tránh nhầm do so nhiều lần.

**Trong bài:** H = 1.084,7, p < 0,001, cỡ ảnh hưởng ε² = 0,503 (lớn); cả 6 cặp p < 0,001. Cùng kết luận với ANOVA → **kết luận "phân khúc ảnh hưởng mạnh đến TDP" vững chắc**, và đây là cách nhóm chọn làm kết luận chính.

## 9. Hồi quy tuyến tính bội

Đây là phần "đỉnh" của bài. Nên dành nhiều thời gian nhất.

### 9.1. Ý tưởng: công thức nấu ăn

**Hình dung:** TDP giống độ ngon của món canh; mỗi yếu tố là một nguyên liệu. Hồi quy tìm "công thức" nói mỗi nguyên liệu đóng góp bao nhiêu. Mô hình của nhóm:

**TDP ≈ −30,1 + 3,89 × (số nhân) + 27,6 × (xung nhịp GHz) + 0,245 × (tiến trình nm) + (cộng/trừ theo phân khúc) − 8,98 (nếu có tùy chọn nhúng)**

**Ví dụ dễ nhớ:** chip Desktop, 4 nhân, 3,0 GHz, 22 nm, không tùy chọn nhúng: −30,1 + 15,6 + 82,9 + 5,4 ≈ **73,7 W**. Cùng thông số nhưng là Server: cộng thêm 21,8 W, thành khoảng **95,6 W**; là Mobile: trừ 15,6 W, còn khoảng **58,1 W**.

### 9.2. "Giữ các biến khác không đổi" nghĩa là gì?

Là **so sánh công bằng, táo với táo**: khi nói "thêm 1 nhân làm TDP tăng 3,89 W", ta đang so hai chip giống hệt nhau về mọi thứ khác, chỉ khác 1 nhân. Nhờ vậy ta tách được ảnh hưởng riêng của từng yếu tố. Đây là thứ mà t-test đơn lẻ không làm được, và là cách gỡ "biến gây nhiễu" như ở mục 6.

### 9.3. Làm sao tìm ra công thức? (OLS)

**Hình dung:** có 1.727 chấm trên giấy, ta thả một sợi dây thẳng, rồi xoay kéo sợi dây sao cho **tổng bình phương khoảng cách từ các chấm tới dây là nhỏ nhất**. "Bình phương" để sai lệch lớn bị phạt nặng. Cách này gọi là **bình phương tối thiểu (OLS)**.

### 9.4. Biến định tính vào công thức bằng "công tắc"

Phân khúc có 4 mức nên cần 3 "công tắc" bật/tắt (Mobile, Server, Embedded), còn **Desktop là mốc** để so (tất cả công tắc tắt). Hệ số của công tắc = "chênh bao nhiêu so với Desktop".

### 9.5. Đọc kết quả

- **R² = 0,7844:** mô hình giải thích khoảng **78%** sự khác nhau về TDP. Ví dụ: như nói "78% chênh lệch điểm thi là do giờ học, ôn tập và trường lớp; 22% còn lại do những thứ ta chưa đo được".
- **Kiểm định F:** hỏi "có ít nhất một nguyên liệu thật sự đóng góp không?" → p < 0,001, có.
- **Kiểm định t của từng hệ số:** hỏi "nguyên liệu này đóng góp thật hay chỉ là may rủi?" Hầu hết p < 0,001.
- **Hiện tượng thú vị:** Embedded **không** có ý nghĩa (p = 0,7348), dù Tukey nói Embedded thấp hơn Desktop 30 W. Giải thích: sự "nguội" đó đã được các nguyên liệu khác giải thích (Embedded ít nhân hơn Server, tiến trình khác, xung nhịp thấp). **Hai kết luận không mâu thuẫn:** Tukey so "thô", hồi quy so "sau khi cân bằng các thứ khác".
- **Cẩn thận với −8,98 W của tùy chọn nhúng:** biến này gần như trùng với Embedded. Như hai người cùng làm một việc: khó chia công cho từng người. Nên nói là xu hướng, đừng nói là ảnh hưởng độc lập chắc chắn.

### 9.6. Đa cộng tuyến (VIF)

**Hình dung:** hai bạn cùng hét một câu một lúc, bạn nghe không biết ai nói. Hai biến giải thích "nói giống nhau" thì mô hình không phân biệt được vai trò từng biến, hệ số trở nên bấp bênh. **VIF** đo mức "hét trùng"; VIF dưới 5 là an toàn (với biến nhiều mức dùng GVIF^(1/2Df), so với 2,24). Trong bài tất cả ≤ 1,32 → **an toàn**.

### 9.7. Kiểm tra giả định: nhìn phần dư

**Phần dư = dự đoán sai bao nhiêu.** Nếu mô hình tốt, phần dư phải như "tiếng ồn ngẫu nhiên": không có quy luật. Nhóm kiểm tra:

- **Phần dư có chuông không?** (Q-Q plot, Shapiro-Wilk) → không.
- **Độ sai có đều không?** (Breusch-Pagan) → không. Đồ thị có **hình phễu**: chip công suất càng lớn thì dự đoán càng lệch. Giống thợ may: đo áo trẻ em sai vài mm thì ổn, nhưng đo áo choàng người khổng lồ sai cả vài cm.
- **Có điểm "gây chấn động" không?** (khoảng cách Cook) → có 74/1.727 chip (≈4,3%): những "học sinh" làm đường thẳng bị kéo lệch.

Hệ quả nên nói thẳng: **hệ số vẫn là ước lượng hợp lí, nhưng p-value và khoảng tin cậy chỉ mang tính tham khảo.** Nhóm nêu điều này như một hạn chế chứ không giấu.

### 9.8. Hai mô hình: TDP và log(TDP)

**Hình dung thang log:** tăng từ 10 W lên 20 W và từ 100 W lên 200 W đều là "gấp đôi", nhưng chênh lệch tuyệt đối 10 W và 100 W. Dùng log là đổi sang "thang phần trăm", hợp với dữ liệu lệch phải mà càng to càng loe. Khi đổi ngược từ log về Watt cần một "hệ số bù hao" (smearing), vì trung bình của hàm mũ không bằng hàm mũ của trung bình.

### 9.9. Chọn biến bằng AIC

**Hình dung:** thu dọn tủ đồ. Thêm biến làm mô hình khớp hơn nhưng phức tạp hơn. **AIC** là điểm số "phạt sự rườm rà": giữ món nào còn đáng giữ. Kết quả: cả 5 biến đều được giữ, AIC không đổi (2.424,9), nghĩa là không có biến thừa.

### 9.10. Đánh giá dự báo: ôn đề rồi thi đề mới

Chia dữ liệu: **80% để "học"** (tập huấn luyện), **20% "giấu đi" để thi** (tập kiểm tra, 432 chip). Nếu chỉ chấm bằng chính đề đã ôn thì sẽ tự khen quá lời. Hai thước đo:

- **MAE** = sai trung bình bao nhiêu W.
- **RMSE** = giống MAE nhưng **phạt nặng sai lớn**. RMSE lớn hơn nhiều MAE nghĩa là có vài lần "trượt rất xa".

| Mô hình | MAE | RMSE | R² kiểm tra |
| --- | --- | --- | --- |
| Mô hình 1: TDP | 15,73 W | 21,51 W | 0,739 |
| Mô hình 2: log(TDP) | 19,38 W | 32,68 W | 0,397 |

**Cách kể:** mô hình 1 dự báo chip lạ sai trung bình khoảng 16 W, và giải thích được \~74% trên dữ liệu chưa thấy → khá ổn. Mô hình log "đẹp" hơn về giả định nhưng khi quy về Watt lại dự báo tệ hơn, nhất là các chip công suất lớn (RMSE 32,68). **Bài học:** mô hình đẹp trên giấy chưa chắc dự báo tốt, nên phải thi trên đề mới.

## 10. Bảng tóm tắt: một câu cho mỗi phương pháp

| Phương pháp | Một câu dễ nhớ | Kết quả bài |
| --- | --- | --- |
| Khoảng tin cậy | Ném lưới thay vì mũi lao | 4 lưới không chồng nhau |
| t-test, Wilcoxon một mẫu | Tín hiệu có át tiếng ồn không? | Desktop ≈ 65 W: không bác bỏ |
| Kiểm định tỉ lệ | Đồng xu có công bằng không? | Chỉ \~25% có tùy chọn nhúng |
| Tương quan | Hai biến có cùng "nhảy" không? | Số nhân, xung nhịp có; tiến trình yếu |
| Welch, rank-sum | So hai lớp, không giả sử đều | Yes thấp hơn No \~22,5 W |
| ANOVA, Tukey | Chênh giữa nhóm có lớn hơn chênh trong nhóm? | F = 597; 6/6 cặp khác |
| Kruskal-Wallis | Xếp hạng toàn bộ rồi so | Cùng kết luận, vững |
| Hồi quy bội | Công thức nấu ăn của TDP | R² = 0,78; MAE ≈ 16 W |

## 11. Câu hỏi thầy có thể hỏi và gợi ý trả lời

**1. Tại sao dùng mức ý nghĩa 0,05?** Đó là quy ước phổ biến: chấp nhận 5% rủi ro kết án nhầm. Nhóm giữ cố định cho mọi kiểm định để nhất quán; với các kết quả của bài, p thường nhỏ hơn 0,001 nên kết luận không phụ thuộc vào việc chọn 0,05 hay 0,01.

**2. Vì sao dùng cả ANOVA lẫn Kruskal-Wallis?** ANOVA bị vi phạm giả định chuẩn và đồng nhất phương sai, nên nhóm dùng Kruskal-Wallis để kiểm tra chéo. Hai cách cho cùng kết luận nên kết luận đáng tin.

**3. Sao không dùng t-test thường mà dùng Welch?** Hai nhóm có độ lệch chuẩn khác nhau (47,1 và 31,4), Welch không đòi phương sai bằng nhau nên an toàn hơn và hầu như không thiệt gì khi hai nhóm thực ra giống nhau.

**4. Tương quan có phải nhân quả không?** Không. Tương quan chỉ nói hai biến đi cùng nhau. Ở bài này nhóm có thêm lí do vật lí (nhiều nhân, xung nhịp cao thì tiêu thụ điện nhiều), nhưng chính phép thống kê không chứng minh nhân quả.

**5. Sao Embedded không có ý nghĩa trong hồi quy mà Tukey lại có?** Tukey so thô, không kiểm soát biến khác. Hồi quy so sau khi cân bằng số nhân, xung nhịp, tiến trình, tùy chọn nhúng. Phần "nguội" của Embedded đã được các biến đó giải thích hết.

**6. Phần dư không chuẩn thì kết quả hồi quy có dùng được không?** Hệ số vẫn là ước lượng hợp lí và mô hình dự báo được (đã kiểm tra trên tập kiểm tra), nhưng p-value và khoảng tin cậy chỉ mang tính tham khảo. Nhóm nêu rõ đây là hạn chế và đề xuất hướng cải thiện (biến đổi khác, hồi quy bền vững).

**7. Vì sao mô hình log kém hơn khi dự báo?** Log giúp giả định đẹp hơn trên thang log, nhưng khi quy về Watt, sai số ở các chip công suất lớn bị khuếch đại nên RMSE lớn (32,68 W). Đây là lí do nhóm đánh giá bằng MAE, RMSE trên tập kiểm tra và chọn mô hình 1 để dự báo.

**8. Dữ liệu là toàn bộ danh mục chip, đâu phải mẫu ngẫu nhiên, sao vẫn suy diễn?** Đúng, đây là hạn chế. Có thể coi các chip là một mẫu từ "quá trình thiết kế của Intel" nhưng các chip cùng dòng không hoàn toàn độc lập. Vì vậy nhóm diễn giải kết quả như xu hướng, không như quy luật tuyệt đối.

**9. Xóa 124 dòng khuyết (5,4%) có làm lệch kết quả không?** Có thể có lệch nếu các dòng thiếu tập trung vào một dòng sản phẩm. Vì tỉ lệ nhỏ và vẫn còn 2.159 quan trắc nên nhóm chọn cách xóa đơn giản; hướng mở rộng là điền khuyết có kiểm soát.

**10. Khác nhau giữa "có ý nghĩa thống kê" và "có ý nghĩa thực tiễn"?** Ý nghĩa thống kê chỉ nói "khó là do may rủi". Ý nghĩa thực tiễn hỏi "chênh có đủ lớn để quan tâm không". Ví dụ tiến trình có r = −0,118 với p < 0,001 nhưng quá nhỏ để quan trọng.

## 12. Mẹo trình bày

- **Mỗi slide một ý**, mở bằng hình dung đời thường rồi mới đến công thức; nếu thầy cần công thức thì đã có ở báo cáo.
- **Luôn kết thúc một phương pháp bằng một câu bằng lời thường**, ví dụ: *"Nghĩa là: TDP của Desktop không khác 65 W một cách đáng kể."*
- **Chủ động nêu hạn chế** (vi phạm giả định, biến gây nhiễu, dữ liệu không ngẫu nhiên). Thầy thường đánh giá cao nhóm tự biết giới hạn của mình hơn là nhóm tỏ ra hoàn hảo.
- **Phân vai:** mỗi người đọc thuộc một cặp "hình dung → số liệu trong bài" của phần mình phụ trách, và biết ít nhất hai câu hỏi ở mục 11.
