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
