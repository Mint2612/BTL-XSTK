### Tiền xử lí  

## Đọc dữ liệu 
# data <- read.csv("đường dẫn dữ liệu đã đọc")
data <- read.csv("/home/thai/BTL-XSTK/archive/Intel_CPUs.csv")

## Thống nhất định dạng cho dữ liệu trống
data[data == "N/A"] <- NA
data[data == "NA"] <- NA
data[data == ""] <- NA

View(data)


## Lọc các thông số kĩ thuật
# Đã sửa lỗi chính tả chữ "Available"
data <- data[, c("TDP",                                 # Y: Lượng nhiệt CPU tỏa ra 
                 "nb_of_Cores",                         # số nhân
                 "Processor_Base_Frequency",            # xung nhịp cơ bản
                 "Vertical_Segment",                    # Phân khúc
                 "Lithography",                         # tiến trình (nm)
                 "Embedded_Options_Available" )]        # Tùy chọn nhúng
View(data) 


## Xử lí dữ liệu trống
{
  # Tìm số thực thể khuyết mỗi cột 
  na_count <- colSums(is.na(data))
  print(na_count)
  
  # Xóa các dòng khuyết ở các biến 
  cols_drop <- c("Processor_Base_Frequency", "Embedded_Options_Available","TDP","Lithography")
  data <- data[complete.cases(data[, cols_drop]), ] # Thay // bằng # để không bị lỗi cú pháp

  # Kiểm tra lại số NA từng cột
  print(colSums(is.na(data)))
  View(data)
}

## Thống nhất đơn vị
{
  #  Bar chart DẠNG CHUỖI (thay số bằng #)
  plot_pattern <- function(x, name) {
    p <- trimws(gsub(",", "", as.character(x)))
    p <- gsub("[0-9]+(\\.[0-9]+)?", "#", p)
    tb <- sort(table(p, useNA = "ifany"), decreasing = TRUE)
    counts <- as.vector(tb)
    labs <- names(tb); labs[is.na(labs)] <- "NA"
    par(mar = c(10, 4, 3, 1))
    bp <- barplot(counts, names.arg = labs, las = 2, col = "seagreen",
                  main = paste("Dạng chuỗi:", name),
                  ylab = "Số lượng", ylim = c(0, max(counts) * 1.15))
    text(bp, counts, labels = counts, pos = 3, cex = 0.7)
  }
  
  plot_pattern(data$Processor_Base_Frequency,    "Xung nhịp")
  
  # Đổi xung nhịp về một đơn vị duy nhất: GHz (dạng số)
  {
    f   <- trimws(as.character(data$Processor_Base_Frequency))
    val <- as.numeric(sub("^([0-9.]+).*", "\\1", f))            # lấy số đầu tiên
    data$Processor_Base_Frequency <- ifelse(grepl("MHz", f, ignore.case = TRUE),
                                            val / 1000,          # MHz -> GHz
                                            val)    # GHz giữ nguyên
    plot_pattern(data$Processor_Base_Frequency,    "Xung nhịp")
    
  }
  
  plot_pattern(data$Lithography,                 "Tiến trình")
  plot_pattern(data$TDP,                         "TDP" )
  
  # Đổi các đại lượng còn lại thành dạng số
  {
    data$Lithography <- as.numeric(sub("^([0-9.]+).*", "\\1", trimws(data$Lithography)))  # nm
    data$TDP         <- as.numeric(sub("^([0-9.]+).*", "\\1", trimws(data$TDP)))          # W
    data$nb_of_Cores <- as.numeric(data$nb_of_Cores)
  }
  
  # Đánh index cho các biến định tính 
  {
    print(table(data$Vertical_Segment, useNA = "ifany"))
    print(table(data$Embedded_Options_Available, useNA = "ifany"))   # xem có đúng Yes/No không
    
    data$Vertical_Segment <- factor(data$Vertical_Segment,
                                    levels = c("Desktop", "Mobile", "Server", "Embedded"))
    data$Embedded_Options_Available <- factor(data$Embedded_Options_Available,
                                              levels = c("No", "Yes"))
  }
}

View(data)
### 4. Thống kê mô tả
### Thay TOÀN BỘ hai phần thống kê mô tả cũ (định tính + định lượng) bằng file này,
### dán sau phần tiền xử lí. Cần có sẵn biến `data` đã tiền xử lí.
### Kết quả: Bảng 1-10 xuất ra thư mục "bang/", Hình 1-9 xuất ra thư mục "hinh/".
### Tất cả đều có số thứ tự và tiêu đề; không in gì ra console.

## ======================= 4.0 Chuẩn bị =======================
graphics.off()
par(mar = c(5, 4, 4, 2) + 0.1, mfrow = c(1, 1))
dir.create("hinh", showWarnings = FALSE)
dir.create("bang", showWarnings = FALSE)

col_seg <- c("steelblue", "seagreen", "tomato", "goldenrod")   # Desktop, Mobile, Server, Embedded
col_emb <- c("grey60", "steelblue")                            # No, Yes

vars   <- c("TDP", "nb_of_Cores", "Processor_Base_Frequency", "Lithography")
labels <- c(TDP = "TDP (W)", nb_of_Cores = "Số nhân",
            Processor_Base_Frequency = "Xung nhịp cơ bản (GHz)", Lithography = "Tiến trình (nm)")
short  <- c("TDP", "Số nhân", "Xung nhịp", "Tiến trình")

## Vẽ lên khung Plots VÀ lưu thành PNG
show_save <- function(file, plot_fn, w = 1600, h = 1200) {
  plot_fn()
  png(file.path("hinh", file), width = w, height = h, res = 200)
  plot_fn()
  invisible(dev.off())
}

## Xuất một bảng (data.frame) thành ảnh PNG có tiêu đề "Bảng N. ..."
save_table <- function(file, df, ten, cex = 1) {
  df <- as.data.frame(df, check.names = FALSE, stringsAsFactors = FALSE)
  df[] <- lapply(df, as.character)
  nr <- nrow(df); nc <- ncol(df)
  cw <- sapply(seq_len(nc), function(j) max(nchar(c(names(df)[j], df[[j]]), type = "width"))) + 3
  W  <- sum(cw); x1 <- cumsum(cw); x0 <- x1 - cw
  w_in <- max(W * 0.105 + 0.4, nchar(ten) * 0.1 + 0.4)
  h_in <- (nr + 1) * 0.36 + 0.9
  png(file.path("bang", file), width = w_in * 200, height = h_in * 200, res = 200)
  par(mar = c(0.3, 0.3, 2.6, 0.3))
  plot.new()
  plot.window(xlim = c(0, W), ylim = c(nr + 1, 0), xaxs = "i", yaxs = "i")
  rect(0, 0, W, 1, col = "grey85", border = NA)
  for (j in seq_len(nc)) text((x0[j] + x1[j]) / 2, 0.5, names(df)[j], font = 2, cex = cex)
  for (i in seq_len(nr)) for (j in seq_len(nc)) text((x0[j] + x1[j]) / 2, i + 0.5, df[i, j], cex = cex)
  segments(0, 0:(nr + 1), W, 0:(nr + 1), col = "grey50")
  segments(c(0, W), 0, c(0, W), nr + 1, col = "grey50")
  title(main = ten, line = 0.8, cex.main = 1)
  invisible(dev.off())
}

## Đổi ma trận/bảng chéo thành data.frame có cột tên hàng
with_rn <- function(m, ten_cot) {
  d <- data.frame(rownames(m), as.data.frame.matrix(unclass(m)), check.names = FALSE)
  names(d)[1] <- ten_cot
  rownames(d) <- NULL
  d
}

## ======================= 4.1 Cấu trúc dữ liệu =======================
# Chạy riêng trong console khi cần kiểm tra: str(data); colSums(is.na(data))

## ======================= 4.2 Các bảng (Bảng 1-10) =======================
freq_table <- function(x, ten_nhom) {
  tb <- table(x)
  d <- data.frame(names(tb), as.vector(tb), round(100 * as.vector(prop.table(tb)), 1))
  names(d) <- c(ten_nhom, "Tần số", "Tỉ lệ (%)")
  d
}
tdp_by <- function(g, ten_nhom) {
  s <- tapply(data$TDP, g, function(v) c(n = length(v), TB = mean(v), TrungVi = median(v),
                                         DLC = sd(v), Min = min(v), Max = max(v)))
  d <- data.frame(names(s), round(do.call(rbind, s), 1), row.names = NULL)
  names(d) <- c(ten_nhom, "n", "Trung bình", "Trung vị", "Độ lệch chuẩn", "Min", "Max")
  d
}
skew <- function(x) mean((x - mean(x))^3) / sd(x)^3     # hệ số bất đối xứng

# --- Biến định tính ---
bang1 <- freq_table(data$Vertical_Segment, "Phân khúc")
bang2 <- freq_table(data$Embedded_Options_Available, "Tùy chọn nhúng")
tb2   <- table(data$Vertical_Segment, data$Embedded_Options_Available)
bang3 <- with_rn(tb2, "Phân khúc")
bang4 <- with_rn(round(100 * prop.table(tb2, margin = 1), 1), "Phân khúc")
bang5 <- tdp_by(data$Vertical_Segment, "Phân khúc")
bang6 <- tdp_by(data$Embedded_Options_Available, "Tùy chọn nhúng")

# --- Biến định lượng ---
bang7 <- do.call(rbind, lapply(vars, function(v) {
  x <- data[[v]]
  data.frame(Bien = labels[[v]], n = length(x), TB = mean(x), DLC = sd(x), Min = min(x),
             Q1 = quantile(x, 0.25, names = FALSE), TrungVi = median(x),
             Q3 = quantile(x, 0.75, names = FALSE), Max = max(x), BatDoiXung = skew(x))
}))
bang7[, -1] <- round(bang7[, -1], 2)
names(bang7) <- c("Biến", "n", "Trung bình", "Độ lệch chuẩn", "Min", "Q1", "Trung vị", "Q3", "Max", "Bất đối xứng")

cor_p <- cor(data[, vars], method = "pearson")
cor_s <- cor(data[, vars], method = "spearman")
dimnames(cor_p) <- dimnames(cor_s) <- list(short, short)
bang8 <- with_rn(round(cor_p, 3), "")
bang9 <- with_rn(round(cor_s, 3), "")

bang10 <- aggregate(cbind(nb_of_Cores, Processor_Base_Frequency, Lithography) ~ Vertical_Segment,
                    data = data, FUN = mean)
bang10[, -1] <- round(bang10[, -1], 2)
names(bang10) <- c("Phân khúc", "Số nhân", "Xung nhịp (GHz)", "Tiến trình (nm)")

# --- Xuất ảnh các bảng ---
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
# Muốn xem nhanh trong RStudio: View(bang1) ... View(bang10)

## ======================= 4.3 Các hình (Hình 1-9) =======================

## --- Biến định tính: Hình 1-5 ---
bar_cat <- function(x, ten, xlab, col) {
  tb <- table(x)
  bp <- barplot(tb, col = col, main = ten, xlab = xlab, ylab = "Số lượng",
                ylim = c(0, max(tb) * 1.2))
  text(bp, tb, labels = paste0(tb, "\n(", round(100 * prop.table(tb), 1), "%)"), pos = 3, cex = 0.8)
}

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

## --- Biến định lượng: Hình 6-9 (histogram) ---
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

## Biến rời rạc (số nhân, tiến trình): dùng biểu đồ cột thay cho histogram
## nhom = NULL: mỗi giá trị một cột; nhom = factor đã gộp: dùng để gộp các giá trị hiếm
bar_discrete <- function(v, n_hinh, color, nhom = NULL) {
  x <- data[[v]]
  g <- if (is.null(nhom)) factor(x, levels = sort(unique(x))) else nhom
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

show_save("hinh06_hist_tdp.png",       function() hist_var("TDP", 6, "steelblue"))
show_save("hinh07_bar_sonhan.png",     function()
  bar_discrete("nb_of_Cores", 7, "seagreen",
               nhom = cut(data$nb_of_Cores, breaks = c(0, 1, 2, 4, 6, 8, 12, 16, Inf),
                          labels = c("1", "2", "3-4", "5-6", "7-8", "9-12", "13-16", "Trên 16"))))
show_save("hinh08_hist_xungnhip.png",  function() hist_var("Processor_Base_Frequency", 8, "tomato"))
show_save("hinh09_bar_tientrinh.png",  function() bar_discrete("Lithography", 9, "goldenrod"))