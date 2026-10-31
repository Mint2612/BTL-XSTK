### Tiền xử lí  

## Đọc dữ liệu 
# data <- read.csv("đường dẫn dữ liệu đã đọc")
data <- read.csv("/home/thai/BTL-XSTK/archive/Intel_CPUs.csv")
View(data)

## Thống nhất định dạng cho dữ liệu trống
data[data == "N/A"] <- NA
data[data == "NA"] <- NA
data[data == ""] <- NA

## Lọc các thông số kĩ thuật
data <- data[, c("TDP",                                 # Y: Lượng nhiệt CPU tỏa ra 
                 "nb_of_Cores",                         # số nhân
                 "Processor_Base_Frequency",            # xung nhịp cơ bản
                 "Vertical_Segment",                    # Phân khúc           # bộ nhớ đệm
                 "Lithography",                         # tiến trình (nm)
                 "Intel_64_" )]                         # Kiến trúc (Thêm dấu đóng ngoặc vuông nếu thiếu)
View(data) # code bug gì -> Đã sửa thành dấu #
## Lọc các thông số kĩ thuật
data <- data[, c("TDP",                                 # Y: Lượng nhiệt CPU tỏa ra 
                 "nb_of_Cores",                         # số nhân
                 "Processor_Base_Frequency",            # xung nhịp cơ bản
                 "Vertical_Segment",                    # Phân khúc           # bộ nhớ đệm
                 "Lithography",                         # tiến trình (nm)
                 "Intel_64_" )]                         # Kiến trúc (Thêm dấu đóng ngoặc vuông nếu thiếu)
View(data) 


## Xử lí dữ liệu trống
{
  na_count <- colSums(is.na(data))
  print(na_count)
  
  ## Xóa các dòng khuyết ở Cache, Lithography, Processor_Base_Frequency
  cols_drop <- c("Processor_Base_Frequency")
  data <- data[complete.cases(data[, cols_drop]), ]
  
  ## Kiểm tra lại số NA từng cột
  print(colSums(is.na(data)))
  View(data)
}

# Bar chart các giá trị xuất hiện nhiều nhất mỗi cột
plot_top <- function(x, name, top = 15) {
  tb     <- sort(table(x, useNA = "ifany"), decreasing = TRUE)
  n_uniq <- length(tb)
  counts <- head(as.vector(tb), top)
  labs   <- head(names(tb), top)
  labs[is.na(labs)] <- "NA"
  par(mar = c(10, 4, 3, 1))
  bp <- barplot(counts, names.arg = labs, las = 2, col = "steelblue",
                main = paste0(name, " (", n_uniq, " giá trị khác nhau)"),
                ylab = "Số lượng", ylim = c(0, max(counts) * 1.15))
  text(bp, counts, labels = counts, pos = 3, cex = 0.7)
}
for (col in names(data)) plot_top(data[[col]], col)

## Xử lí nhóm thiểu số, không đủ dữ liệu xác minh trong mỗi oột
#  Bar chart DẠNG CHUỖI (thay số bằng #)
{
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
  plot_pattern(data$Lithography,                 "Tiến trình")
  plot_pattern(data$TDP,                         "TDP" )
}

View(data)
