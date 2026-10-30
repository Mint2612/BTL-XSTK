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
data <- data[, c("Recommended_Customer_Price",          # Y: giá
                       "nb_of_Cores",                         # số nhân
                       "Processor_Base_Frequency",            # xung nhịp cơ bản
                       "Cache",                               # bộ nhớ đệm
                       "Lithography",                         # tiến trình (nm)
                       "Vertical_Segment",                    # phân khúc
                       "Intel_Hyper_Threading_Technology_")]  # có/không phân luồng
View(data)

## Xử lí dữ liệu trống
{
na_count <- colSums(is.na(data))
print(na_count)

## Xóa các dòng khuyết ở Cache, Lithography, Processor_Base_Frequency
cols_drop <- c("Cache", "Lithography", "Processor_Base_Frequency")
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
  
  plot_pattern(data$Recommended_Customer_Price,  "Giá")
  
  plot_pattern(data$Processor_Base_Frequency,    "Xung nhịp")
  ## Xóa xung nhịp quá bé ( cpu cũ và thiểu số )
  {
    data <- data[!grepl("MHz", data$Processor_Base_Frequency, ignore.case = TRUE), ]

    ## Còn lại toàn GHz -> chuyển sang số (đơn vị GHz)
    data$Processor_Base_Frequency <- as.numeric(gsub("[^0-9.]", "", data$Processor_Base_Frequency))
    
    ## Kiểm tra
    plot_pattern(data$Processor_Base_Frequency,    "Xung nhịp")
    
  }
  
  plot_pattern(data$Cache,                       "Cache")
  # xóa các loại cache quá ít số liệu 
  {
    ## Xóa các dòng Cache có dạng chuỗi hiếm
    pat <- trimws(gsub(",", "", as.character(data$Cache)))
    pat <- gsub("[0-9]+(\\.[0-9]+)?", "#", pat)       # giống plot_pattern
    
    drop_pat <- c("# KB", "# MB Last Level Cache", "# KB SmartCache")
    data <- data[!(pat %in% drop_pat), ]
    ## Kiểm tra lại: chỉ còn 4 dạng
    plot_pattern(data$Cache, "Cache")
  }
  
  plot_pattern(data$Lithography,                 "Tiến trình")
  
}
View(data)

plot_pattern(data$Recommended_Customer_Price,  "Giá")
## Xử lí giá
{
  ## Giữ lại bản đầy đủ (kể cả dòng không có giá) cho phần thống kê mô tả
  data_full <- data
  
  ## Bản dùng cho mô hình: bỏ dòng không có giá
  data <- data[!is.na(data$Recommended_Customer_Price), ]
  
  ## Bỏ "$" và dấu phẩy, khoảng giá lấy trung bình 2 đầu
  price_to_num <- function(x) {
    x <- gsub("[$,]", "", as.character(x))
    sapply(strsplit(x, "-"), function(p) mean(as.numeric(trimws(p))))
  }
  data$Recommended_Customer_Price <- price_to_num(data$Recommended_Customer_Price)
  
  cat("Dòng đầy đủ:", nrow(data_full), "| Dòng dùng cho mô hình:", nrow(data), "\n")
  summary(data$Recommended_Customer_Price)
  hist(data$Recommended_Customer_Price, breaks = 30,
       main = "Phân bố giá (USD)", xlab = "USD", col = "steelblue")
}
## Giá lệch phải -> thêm cột log(giá) để dùng cho mô hình
cat("Trung bình:", mean(data$Recommended_Customer_Price),
    "| Trung vị:", median(data$Recommended_Customer_Price), "\n")

data$Log_Price <- log(data$Recommended_Customer_Price)

par(mfrow = c(1, 2))
hist(data$Recommended_Customer_Price, breaks = 30,
     main = "Giá gốc", xlab = "USD", col = "steelblue")
hist(data$Log_Price, breaks = 30,
     main = "log(Giá)", xlab = "log(USD)", col = "seagreen")
par(mfrow = c(1, 1))

## Xem giá theo phân khúc để hiểu đuôi dài từ đâu ra
boxplot(Recommended_Customer_Price ~ Vertical_Segment, data = data,
        log = "y", las = 2, col = "steelblue",
        main = "Giá theo phân khúc (trục log)", ylab = "USD")
