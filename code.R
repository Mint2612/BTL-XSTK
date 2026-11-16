###############################################################################
#  BTL Xác suất Thống kê (MT2013) - Nhóm 19
#  Đề tài: Phân tích các yếu tố ảnh hưởng đến TDP của vi xử lí Intel
#
#  CẤU TRÚC FILE
#    0. Cấu hình & hàm tiện ích
#    3. Tiền xử lí số liệu
#    4. Thống kê mô tả          -> Bảng 1-10,  Hình 1-9
#    5. Thống kê suy diễn       -> Bảng 11-20, Hình 10-13
#         5.1 ANOVA một nhân tố (TDP ~ Vertical_Segment) + Tukey HSD
#         5.2 Kruskal-Wallis + Wilcoxon cặp (Bonferroni)
#         5.3 So sánh TDP theo Embedded_Options_Available
#         5.4 Hồi quy tuyến tính bội (OLS), VIF, MAE / RMSE
#
#  KẾT QUẢ: bảng -> thư mục "bang/" (PNG + CSV), hình -> thư mục "hinh/"
#  CÁCH CHẠY: sửa DATA_PATH rồi chạy toàn bộ file (source) từ trên xuống.
###############################################################################


# ============================== 0. CẤU HÌNH =================================

DATA_PATH <- "/home/thai/Desktop/Github/xstk/BTL-XSTK/archive/Intel_CPUs.csv"   # <-- sửa đường dẫn
ALPHA     <- 0.05                                            # mức ý nghĩa
SEED      <- 2026                                            # cố định chia train/test
TRAIN_PCT <- 0.8                                             # tỉ lệ tập huấn luyện

dir.create("hinh", showWarnings = FALSE)
dir.create("bang", showWarnings = FALSE)

# Không cần cài thêm thư viện nào: toàn bộ code chỉ dùng R base.

# Biến & nhãn dùng chung
vars   <- c("TDP", "nb_of_Cores", "Processor_Base_Frequency", "Lithography")
labels <- c(TDP = "TDP (W)", nb_of_Cores = "Số nhân",
            Processor_Base_Frequency = "Xung nhịp cơ bản (GHz)",
            Lithography = "Tiến trình (nm)")
short   <- c("TDP", "Số nhân", "Xung nhịp", "Tiến trình")
col_seg <- c("steelblue", "seagreen", "tomato", "goldenrod")  # Desktop, Mobile, Server, Embedded
col_emb <- c("grey60", "steelblue")                           # No, Yes


# ======================== 0.1 HÀM TIỆN ÍCH (dùng chung) ======================

# Vẽ ra khung Plots rồi lưu PNG vào "hinh/"
show_save <- function(file, plot_fn, w = 1600, h = 1200) {
  plot_fn()
  png(file.path("hinh", file), width = w, height = h, res = 200)
  plot_fn()
  invisible(dev.off())
}

# Xuất data.frame thành ảnh PNG (có tiêu đề "Bảng N. ...") + file CSV cùng tên
save_table <- function(file, df, ten, cex = 1) {
  df <- as.data.frame(df, check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(df, file.path("bang", sub("\\.png$", ".csv", file)),
            row.names = FALSE, fileEncoding = "UTF-8")
  df[] <- lapply(df, as.character)
  nr <- nrow(df); nc <- ncol(df)
  
  # độ rộng cột theo số ký tự dài nhất
  cw <- sapply(seq_len(nc), function(j)
    max(nchar(c(names(df)[j], df[[j]]), type = "width"))) + 3
  W  <- sum(cw); x1 <- cumsum(cw); x0 <- x1 - cw
  w_in <- max(W * 0.105 + 0.4, nchar(ten) * 0.1 + 0.4)
  h_in <- (nr + 1) * 0.36 + 0.9
  
  png(file.path("bang", file), width = w_in * 200, height = h_in * 200, res = 200)
  par(mar = c(0.3, 0.3, 2.6, 0.3))
  plot.new()
  plot.window(xlim = c(0, W), ylim = c(nr + 1, 0), xaxs = "i", yaxs = "i")
  rect(0, 0, W, 1, col = "grey85", border = NA)                       # hàng tiêu đề
  for (j in seq_len(nc)) text((x0[j] + x1[j]) / 2, 0.5, names(df)[j], font = 2, cex = cex)
  for (i in seq_len(nr)) for (j in seq_len(nc))
    text((x0[j] + x1[j]) / 2, i + 0.5, df[i, j], cex = cex)
  segments(0, 0:(nr + 1), W, 0:(nr + 1), col = "grey50")              # kẻ ngang
  segments(c(0, W), 0, c(0, W), nr + 1, col = "grey50")               # viền dọc
  title(main = ten, line = 0.8, cex.main = 1)
  invisible(dev.off())
}

# Ma trận/bảng chéo -> data.frame có cột tên hàng
with_rn <- function(m, ten_cot) {
  d <- data.frame(rownames(m), as.data.frame.matrix(unclass(m)), check.names = FALSE)
  names(d)[1] <- ten_cot
  rownames(d) <- NULL
  d
}

# Định dạng p-value
fmt_p <- function(p) ifelse(p < 0.001, "<0.001", sprintf("%.4f", p))

# Kết luận theo p-value
ket_luan <- function(p, alpha = ALPHA)
  ifelse(p < alpha, "Bác bỏ H0", "Không bác bỏ H0")


# ========================= 3. TIỀN XỬ LÍ SỐ LIỆU ============================

## 3.1 Đọc dữ liệu, thống nhất giá trị trống ("N/A", "NA", "") thành NA
data <- read.csv(DATA_PATH, na.strings = c("N/A", "NA", ""), stringsAsFactors = FALSE)

## 3.2 Lọc 6 biến phục vụ đề tài
data <- data[, c("TDP",                          # Y: công suất thiết kế nhiệt
                 "nb_of_Cores",                  # số nhân
                 "Processor_Base_Frequency",     # xung nhịp cơ bản
                 "Vertical_Segment",             # phân khúc
                 "Lithography",                  # tiến trình (nm)
                 "Embedded_Options_Available")]  # tùy chọn nhúng

## 3.3 Xử lí dữ liệu khuyết: xóa dòng thiếu ở các biến cần dùng
print(colSums(is.na(data)))                                  # số NA trước xử lí
cols_drop <- c("TDP", "Processor_Base_Frequency", "Lithography", "Embedded_Options_Available")
data <- data[complete.cases(data[, cols_drop]), ]
print(colSums(is.na(data)))                                  # kiểm tra lại: phải bằng 0

## 3.4 Thống nhất đơn vị và chuyển sang dạng số

# (Tùy chọn) Biểu đồ "dạng chuỗi": thay mọi số bằng '#' để phát hiện đơn vị lẫn lộn
plot_pattern <- function(x, name) {
  p  <- gsub("[0-9]+(\\.[0-9]+)?", "#", trimws(gsub(",", "", as.character(x))))
  tb <- sort(table(p, useNA = "ifany"), decreasing = TRUE)
  par(mar = c(10, 4, 3, 1))
  bp <- barplot(as.vector(tb), names.arg = ifelse(is.na(names(tb)), "NA", names(tb)),
                las = 2, col = "seagreen", main = paste("Dạng chuỗi:", name),
                ylab = "Số lượng", ylim = c(0, max(tb) * 1.15))
  text(bp, as.vector(tb), labels = as.vector(tb), pos = 3, cex = 0.7)
  par(mar = c(5, 4, 4, 2) + 0.1)
}
plot_pattern(data$Processor_Base_Frequency, "Xung nhịp (trước khi đổi đơn vị)")

# Lấy số đầu tiên trong chuỗi (tránh nối nhầm các chữ số phía sau đơn vị)
first_num <- function(x) as.numeric(sub("^([0-9.]+).*", "\\1", trimws(as.character(x))))

# Xung nhịp: đổi MHz -> GHz, giữ nguyên GHz
f <- trimws(as.character(data$Processor_Base_Frequency))
data$Processor_Base_Frequency <- ifelse(grepl("MHz", f, ignore.case = TRUE),
                                        first_num(f) / 1000, first_num(f))
# Các biến còn lại: bỏ đơn vị, ép kiểu số
data$Lithography <- first_num(data$Lithography)   # nm
data$TDP         <- first_num(data$TDP)           # W
data$nb_of_Cores <- as.numeric(data$nb_of_Cores)

## 3.5 Chuyển biến định tính sang factor (mức đầu tiên là mức mốc)
data$Vertical_Segment <- factor(data$Vertical_Segment,
                                levels = c("Desktop", "Mobile", "Server", "Embedded"))
data$Embedded_Options_Available <- factor(data$Embedded_Options_Available,
                                          levels = c("No", "Yes"))

## 3.6 Kiểm tra lại cấu trúc dữ liệu sạch
str(data)    # kì vọng: 2159 obs. of 6 variables, không còn NA


# ============================ 4. THỐNG KÊ MÔ TẢ ==============================

graphics.off()
par(mar = c(5, 4, 4, 2) + 0.1, mfrow = c(1, 1))

## ---- 4.1 Các hàm tạo bảng ----
freq_table <- function(x, ten_nhom) {                         # tần số + tỉ lệ
  tb <- table(x)
  d  <- data.frame(names(tb), as.vector(tb), round(100 * as.vector(prop.table(tb)), 1))
  names(d) <- c(ten_nhom, "Tần số", "Tỉ lệ (%)")
  d
}

tdp_by <- function(g, ten_nhom) {                             # thống kê TDP theo nhóm
  s <- tapply(data$TDP, g, function(v)
    c(n = length(v), TB = mean(v), TrungVi = median(v), DLC = sd(v), Min = min(v), Max = max(v)))
  d <- data.frame(names(s), round(do.call(rbind, s), 1), row.names = NULL)
  names(d) <- c(ten_nhom, "n", "Trung bình", "Trung vị", "Độ lệch chuẩn", "Min", "Max")
  d
}

skew <- function(x) mean((x - mean(x))^3) / sd(x)^3           # hệ số bất đối xứng

## ---- 4.2 Bảng 1-10 ----
tb2 <- table(data$Vertical_Segment, data$Embedded_Options_Available)

bang1 <- freq_table(data$Vertical_Segment, "Phân khúc")
bang2 <- freq_table(data$Embedded_Options_Available, "Tùy chọn nhúng")
bang3 <- with_rn(tb2, "Phân khúc")
bang4 <- with_rn(round(100 * prop.table(tb2, margin = 1), 1), "Phân khúc")
bang5 <- tdp_by(data$Vertical_Segment, "Phân khúc")
bang6 <- tdp_by(data$Embedded_Options_Available, "Tùy chọn nhúng")

bang7 <- do.call(rbind, lapply(vars, function(v) {
  x <- data[[v]]
  data.frame(Bien = labels[[v]], n = length(x), TB = mean(x), DLC = sd(x), Min = min(x),
             Q1 = quantile(x, 0.25, names = FALSE), TrungVi = median(x),
             Q3 = quantile(x, 0.75, names = FALSE), Max = max(x), BatDoiXung = skew(x))
}))
bang7[, -1] <- round(bang7[, -1], 2)
names(bang7) <- c("Biến", "n", "Trung bình", "Độ lệch chuẩn", "Min", "Q1",
                  "Trung vị", "Q3", "Max", "Bất đối xứng")

cor_p <- cor(data[, vars], method = "pearson")
cor_s <- cor(data[, vars], method = "spearman")
dimnames(cor_p) <- dimnames(cor_s) <- list(short, short)
bang8 <- with_rn(round(cor_p, 3), "")
bang9 <- with_rn(round(cor_s, 3), "")

bang10 <- aggregate(cbind(nb_of_Cores, Processor_Base_Frequency, Lithography) ~ Vertical_Segment,
                    data = data, FUN = mean)
bang10[, -1] <- round(bang10[, -1], 2)
names(bang10) <- c("Phân khúc", "Số nhân", "Xung nhịp (GHz)", "Tiến trình (nm)")

save_table("bang01.png", bang1,  "Bảng 1. Tần số và tỉ lệ số CPU theo phân khúc")
save_table("bang02.png", bang2,  "Bảng 2. Tần số và tỉ lệ số CPU theo tùy chọn nhúng")
save_table("bang03.png", bang3,  "Bảng 3. Số CPU theo phân khúc và tùy chọn nhúng")
save_table("bang04.png", bang4,  "Bảng 4. Tỉ lệ (%) tùy chọn nhúng trong từng phân khúc")
save_table("bang05.png", bang5,  "Bảng 5. Thống kê TDP (W) theo phân khúc")
save_table("bang06.png", bang6,  "Bảng 6. Thống kê TDP (W) theo tùy chọn nhúng")
save_table("bang07.png", bang7,  "Bảng 7. Thống kê mô tả các biến định lượng")
save_table("bang08.png", bang8,  "Bảng 8. Ma trận tương quan Pearson")
save_table("bang09.png", bang9,  "Bảng 9. Ma trận tương quan Spearman")
save_table("bang10.png", bang10, "Bảng 10. Trung bình các biến định lượng X theo phân khúc")

## ---- 4.3 Hình 1-9 ----
# Biểu đồ cột cho biến định tính (kèm số lượng và %)
bar_cat <- function(x, ten, xlab, col) {
  tb <- table(x)
  bp <- barplot(tb, col = col, main = ten, xlab = xlab, ylab = "Số lượng",
                ylim = c(0, max(tb) * 1.2))
  text(bp, tb, labels = paste0(tb, "\n(", round(100 * prop.table(tb), 1), "%)"),
       pos = 3, cex = 0.8)
}

# Histogram cho biến liên tục (kèm đường trung bình và trung vị)
hist_var <- function(v, n_hinh, color) {
  x <- data[[v]]
  hist(x, breaks = "FD", col = color, border = "white",
       main = paste0("Hình ", n_hinh, ". Phân bố ", labels[[v]]),
       xlab = labels[[v]], ylab = "Số lượng")
  abline(v = c(mean(x), median(x)), col = c("red", "darkgreen"), lty = c(1, 2), lwd = 2)
  legend("topright",
         legend = c(sprintf("Trung bình = %.2f", mean(x)), sprintf("Trung vị = %.2f", median(x))),
         col = c("red", "darkgreen"), lty = c(1, 2), lwd = 2, bty = "n")
}

# Biểu đồ cột cho biến rời rạc; nhom = factor đã gộp để gộp giá trị hiếm
bar_discrete <- function(v, n_hinh, color, nhom = NULL) {
  x  <- data[[v]]
  g  <- if (is.null(nhom)) factor(x, levels = sort(unique(x))) else nhom
  tb <- table(g)
  bp <- barplot(tb, col = color, border = NA,
                main = paste0("Hình ", n_hinh, ". Phân bố ", labels[[v]]),
                xlab = if (is.null(nhom)) labels[[v]] else paste0(labels[[v]], " (gộp nhóm)"),
                ylab = "Số lượng", ylim = c(0, max(tb) * 1.25))
  text(bp, tb, labels = tb, pos = 3, cex = 0.8)
  legend("topright",
         legend = c(sprintf("Trung bình = %.2f", mean(x)), sprintf("Trung vị = %.2f", median(x))),
         bty = "n")
}

# Biến định tính: Hình 1-5
show_save("hinh01_phankhuc.png", function()
  bar_cat(data$Vertical_Segment, "Hình 1. Số CPU theo phân khúc", "Phân khúc", col_seg))

show_save("hinh02_tuychonnhung.png", function()
  bar_cat(data$Embedded_Options_Available, "Hình 2. Số CPU theo tùy chọn nhúng",
          "Có tùy chọn nhúng", col_emb))

show_save("hinh03_nhung_theo_phankhuc.png", function()
  barplot(t(prop.table(tb2, margin = 1)), col = col_emb,
          legend.text = c("No", "Yes"), args.legend = list(x = "topright"),
          main = "Hình 3. Tùy chọn nhúng theo phân khúc", xlab = "Phân khúc", ylab = "Tỉ lệ"))

show_save("hinh04_tdp_phankhuc.png", function()
  boxplot(TDP ~ Vertical_Segment, data = data, col = col_seg,
          main = "Hình 4. TDP theo phân khúc", xlab = "Phân khúc", ylab = "TDP (W)"))

show_save("hinh05_tdp_tuychonnhung.png", function()
  boxplot(TDP ~ Embedded_Options_Available, data = data, col = col_emb,
          main = "Hình 5. TDP theo tùy chọn nhúng", xlab = "Có tùy chọn nhúng", ylab = "TDP (W)"))

# Biến định lượng: Hình 6-9
show_save("hinh06_hist_tdp.png", function() hist_var("TDP", 6, "steelblue"))

show_save("hinh07_bar_sonhan.png", function()
  bar_discrete("nb_of_Cores", 7, "seagreen",
               nhom = cut(data$nb_of_Cores, breaks = c(0, 1, 2, 4, 6, 8, 12, 16, Inf),
                          labels = c("1", "2", "3-4", "5-6", "7-8", "9-12", "13-16", "Trên 16"))))

show_save("hinh08_hist_xungnhip.png", function() hist_var("Processor_Base_Frequency", 8, "tomato"))
show_save("hinh09_bar_tientrinh.png", function() bar_discrete("Lithography", 9, "goldenrod"))


# ========================== 5. THỐNG KÊ SUY DIỄN =============================
# Mỗi phương pháp: giả thuyết -> kiểm tra giả định -> kết quả -> kết luận.

## ----------------------------------------------------------------------------
## 5.1 ANOVA MỘT NHÂN TỐ: TDP theo Vertical_Segment
##     H0: TDP trung bình của 4 phân khúc bằng nhau
##     H1: có ít nhất một cặp phân khúc có TDP trung bình khác nhau
## ----------------------------------------------------------------------------
fit_aov <- aov(TDP ~ Vertical_Segment, data = data)
res_aov <- residuals(fit_aov)

# Bảng ANOVA (Bảng 11)
a <- summary(fit_aov)[[1]]
bang11 <- data.frame(
  c("Giữa các nhóm (Phân khúc)", "Trong nội bộ nhóm (Phần dư)"),
  a$Df, round(a$`Sum Sq`, 1), round(a$`Mean Sq`, 1),
  c(round(a$`F value`[1], 2), ""), c(fmt_p(a$`Pr(>F)`[1]), ""))
names(bang11) <- c("Nguồn biến thiên", "Bậc tự do", "Tổng bình phương",
                   "Bình phương TB", "F", "p-value")
save_table("bang11.png", bang11, "Bảng 11. Bảng ANOVA một nhân tố: TDP theo phân khúc")

# Kiểm tra giả định (Bảng 12)
sw  <- shapiro.test(res_aov)                                  # chuẩn của phần dư (n < 5000)
bt  <- bartlett.test(TDP ~ Vertical_Segment, data = data)     # đồng nhất phương sai
# Levene (Brown-Forsythe): ANOVA trên |TDP - trung vị nhóm|
z   <- abs(data$TDP - ave(data$TDP, data$Vertical_Segment, FUN = median))
lev <- anova(lm(z ~ data$Vertical_Segment))
bang12 <- data.frame(
  c("Shapiro-Wilk (phần dư chuẩn)", "Bartlett (đồng nhất phương sai)",
    "Levene (đồng nhất phương sai)"),
  c(sprintf("W = %.4f", sw$statistic), sprintf("K² = %.2f", bt$statistic),
    sprintf("F = %.2f", lev$`F value`[1])),
  c(fmt_p(sw$p.value), fmt_p(bt$p.value), fmt_p(lev$`Pr(>F)`[1])),
  ket_luan(c(sw$p.value, bt$p.value, lev$`Pr(>F)`[1])))
names(bang12) <- c("Kiểm định", "Thống kê", "p-value", "Kết luận (α = 0.05)")
save_table("bang12.png", bang12, "Bảng 12. Kiểm tra giả định của ANOVA")

# Q-Q plot phần dư (Hình 10)
show_save("hinh10_qq_anova.png", function() {
  qqnorm(res_aov, main = "Hình 10. Q-Q plot phần dư ANOVA", pch = 20, col = "steelblue")
  qqline(res_aov, col = "red", lwd = 2)
})

# So sánh bội Tukey HSD (Bảng 13)
tk <- TukeyHSD(fit_aov)$Vertical_Segment
bang13 <- data.frame(rownames(tk), round(tk[, c("diff", "lwr", "upr")], 2),
                     fmt_p(tk[, "p adj"]), ket_luan(tk[, "p adj"]), row.names = NULL)
names(bang13) <- c("Cặp phân khúc", "Chênh lệch TB", "Cận dưới 95%", "Cận trên 95%",
                   "p hiệu chỉnh", "Kết luận")
save_table("bang13.png", bang13, "Bảng 13. So sánh bội Tukey HSD của TDP giữa các phân khúc")

## ----------------------------------------------------------------------------
## 5.2 KRUSKAL-WALLIS (phi tham số, thay thế ANOVA khi vi phạm giả định)
##     H0: phân phối TDP của 4 phân khúc như nhau
## ----------------------------------------------------------------------------
kw <- kruskal.test(TDP ~ Vertical_Segment, data = data)
eps2 <- unname(kw$statistic) / (nrow(data) - 1)               # cỡ ảnh hưởng epsilon²
bang14 <- data.frame("TDP ~ Vertical_Segment",
                     round(unname(kw$statistic), 2), unname(kw$parameter),
                     fmt_p(kw$p.value), round(eps2, 3), ket_luan(kw$p.value))
names(bang14) <- c("Mô hình", "H", "Bậc tự do", "p-value", "Cỡ ảnh hưởng ε²", "Kết luận")
save_table("bang14.png", bang14, "Bảng 14. Kiểm định Kruskal-Wallis: TDP theo phân khúc")

# Wilcoxon từng cặp, hiệu chỉnh Bonferroni (Bảng 15)
pw <- suppressWarnings(
  pairwise.wilcox.test(data$TDP, data$Vertical_Segment, p.adjust.method = "bonferroni")$p.value)
pw_chr <- matrix(ifelse(is.na(pw), "-", fmt_p(pw)), nrow = nrow(pw), dimnames = dimnames(pw))
bang15 <- with_rn(pw_chr, "Phân khúc")
save_table("bang15.png", bang15, "Bảng 15. p-value Wilcoxon từng cặp phân khúc (Bonferroni)")

## ----------------------------------------------------------------------------
## 5.3 SO SÁNH TDP THEO Embedded_Options_Available (2 nhóm: No / Yes)
##     H0: TDP trung bình (hoặc phân phối) của 2 nhóm như nhau
## ----------------------------------------------------------------------------
tt <- t.test(TDP ~ Embedded_Options_Available, data = data)   # Welch (không giả định phương sai bằng nhau)
wt <- suppressWarnings(wilcox.test(TDP ~ Embedded_Options_Available, data = data))
bang16 <- data.frame(
  c("t-test Welch", "Wilcoxon rank-sum"),
  c(sprintf("t = %.2f (df = %.0f)", tt$statistic, tt$parameter), sprintf("W = %.0f", wt$statistic)),
  c(fmt_p(tt$p.value), fmt_p(wt$p.value)),
  ket_luan(c(tt$p.value, wt$p.value)))
names(bang16) <- c("Kiểm định", "Thống kê", "p-value", "Kết luận (α = 0.05)")
save_table("bang16.png", bang16, "Bảng 16. So sánh TDP giữa nhóm No và Yes (tùy chọn nhúng)")

## ----------------------------------------------------------------------------
## 5.4 HỒI QUY TUYẾN TÍNH BỘI (OLS)
##     Mô hình 1: TDP        ~ các biến X
##     Mô hình 2: log(TDP)   ~ các biến X   (giảm lệch phải, ổn định phương sai)
## ----------------------------------------------------------------------------

# --- Chia tập huấn luyện / kiểm tra ---
set.seed(SEED)
idx   <- sample(nrow(data), size = round(TRAIN_PCT * nrow(data)))
train <- data[idx, ]
test  <- data[-idx, ]

fml1 <- TDP ~ nb_of_Cores + Processor_Base_Frequency + Lithography +
  Vertical_Segment + Embedded_Options_Available
fml2 <- update(fml1, log(TDP) ~ .)

m1 <- lm(fml1, data = train)
m2 <- lm(fml2, data = train)

# --- Bảng hệ số mô hình 1 (Bảng 17) ---
sm1 <- summary(m1)
ci1 <- confint(m1)
bang17 <- data.frame(rownames(sm1$coefficients),
                     round(sm1$coefficients[, "Estimate"], 3),
                     round(sm1$coefficients[, "Std. Error"], 3),
                     round(sm1$coefficients[, "t value"], 2),
                     fmt_p(sm1$coefficients[, "Pr(>|t|)"]),
                     round(ci1[, 1], 3), round(ci1[, 2], 3), row.names = NULL)
names(bang17) <- c("Hệ số", "Ước lượng", "Sai số chuẩn", "t", "p-value",
                   "CI 95% dưới", "CI 95% trên")
save_table("bang17.png", bang17, "Bảng 17. Hệ số hồi quy mô hình 1 (biến phụ thuộc TDP)", cex = 0.9)

# --- Độ phù hợp của hai mô hình (Bảng 18) ---
fit_stat <- function(m, ten) {
  s <- summary(m); fs <- s$fstatistic
  data.frame(ten, round(s$r.squared, 4), round(s$adj.r.squared, 4),
             round(fs[["value"]], 1), fmt_p(pf(fs[["value"]], fs[["numdf"]], fs[["dendf"]],
                                               lower.tail = FALSE)),
             round(s$sigma, 3))
}
bang18 <- rbind(fit_stat(m1, "Mô hình 1: TDP"), fit_stat(m2, "Mô hình 2: log(TDP)"))
names(bang18) <- c("Mô hình", "R²", "R² hiệu chỉnh", "F", "p-value (F)", "Sai số chuẩn phần dư")
save_table("bang18.png", bang18, "Bảng 18. Độ phù hợp của các mô hình hồi quy (tập huấn luyện)")

# --- Đa cộng tuyến: VIF (Bảng 19). Với biến factor, car::vif trả GVIF^(1/(2*Df)) ---
#      GVIF = det(R_term) * det(R_còn lại) / det(R_tất cả), R = ma trận tương quan các cột X
mm   <- model.matrix(m1)
X    <- mm[, -1]
R    <- cor(X)
asg  <- attr(mm, "assign")[-1]                      # cột X thuộc biến nào
tlab <- attr(terms(m1), "term.labels")
vf <- t(sapply(seq_along(tlab), function(k) {
  i <- which(asg == k)
  g <- det(R[i, i, drop = FALSE]) * det(R[-i, -i, drop = FALSE]) / det(R)
  c(GVIF = g, Df = length(i), Adj = g^(1 / (2 * length(i))))
}))
rownames(vf) <- tlab
bang19 <- data.frame(rownames(vf), round(vf[, "GVIF"], 2), vf[, "Df"],
                     round(vf[, "Adj"], 2),
                     ifelse(vf[, "Adj"]^2 < 5, "Thấp", "Cần xem xét"),
                     row.names = NULL)
names(bang19) <- c("Biến", "GVIF", "Df", "GVIF^(1/(2·Df))", "Mức cộng tuyến")
save_table("bang19.png", bang19, "Bảng 19. Hệ số VIF của mô hình 1")

# --- Biểu đồ chẩn đoán phần dư (Hình 11, 12) ---
diag_plot <- function(m, ten) {
  op <- par(mfrow = c(2, 2), oma = c(0, 0, 2.5, 0))
  on.exit(par(op))
  plot(m, which = 1:4)
  mtext(ten, outer = TRUE, font = 2)
}
show_save("hinh11_chandoan_m1.png", function()
  diag_plot(m1, "Hình 11. Chẩn đoán phần dư - Mô hình 1 (TDP)"))
show_save("hinh12_chandoan_m2.png", function()
  diag_plot(m2, "Hình 12. Chẩn đoán phần dư - Mô hình 2 (log TDP)"))

# --- Đánh giá dự báo trên tập kiểm tra: MAE, RMSE (Bảng 20) ---
pred1 <- predict(m1, newdata = test)
smear <- mean(exp(residuals(m2)))                             # hệ số hiệu chỉnh khi lấy exp()
pred2 <- exp(predict(m2, newdata = test)) * smear             # đưa về đơn vị Watt
pred1 <- pmax(pred1, 0)                                       # TDP không âm

metrics <- function(y, yhat)
  c(MAE  = mean(abs(y - yhat)),
    RMSE = sqrt(mean((y - yhat)^2)),
    R2   = 1 - sum((y - yhat)^2) / sum((y - mean(y))^2))

mt1 <- metrics(test$TDP, pred1)
mt2 <- metrics(test$TDP, pred2)
bang20 <- data.frame(c("Mô hình 1: TDP", "Mô hình 2: log(TDP)"),
                     round(c(mt1["MAE"],  mt2["MAE"]), 2),
                     round(c(mt1["RMSE"], mt2["RMSE"]), 2),
                     round(c(mt1["R2"],   mt2["R2"]), 4))
names(bang20) <- c("Mô hình", "MAE (W)", "RMSE (W)", "R² (tập kiểm tra)")
save_table("bang20.png", bang20,
           sprintf("Bảng 20. So sánh sai số dự báo trên tập kiểm tra (n = %d)", nrow(test)))

# --- Thực tế vs dự báo (Hình 13) ---
show_save("hinh13_thucte_dubao.png", function() {
  op <- par(mfrow = c(1, 2), oma = c(0, 0, 2.5, 0)); on.exit(par(op))
  lim <- range(test$TDP, pred1, pred2)
  plot(test$TDP, pred1, pch = 20, col = "steelblue", xlim = lim, ylim = lim,
       xlab = "TDP thực tế (W)", ylab = "TDP dự báo (W)", main = "Mô hình 1")
  abline(0, 1, col = "red", lwd = 2)
  plot(test$TDP, pred2, pch = 20, col = "seagreen", xlim = lim, ylim = lim,
       xlab = "TDP thực tế (W)", ylab = "TDP dự báo (W)", main = "Mô hình 2 (log)")
  abline(0, 1, col = "red", lwd = 2)
  mtext("Hình 13. TDP thực tế và TDP dự báo trên tập kiểm tra", outer = TRUE, font = 2)
})

## ---- Xem nhanh trong console khi cần ----
# print(bang11); print(bang12); print(bang13); print(bang14); print(bang15)
# print(bang16); print(bang17); print(bang18); print(bang19); print(bang20)
# summary(m1); summary(m2)

###############################################################################
# HẾT
###############################################################################