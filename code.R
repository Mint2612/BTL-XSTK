# data <- read.csv("đường dẫn dữ liệu đã đọc")
data <- read.csv("/home/thai/BTL-XSTK/archive/Intel_CPUs.csv")
View(data)

data[data == "N/A"] <- NA
data[data == "NA"] <- NA
data[data == ""] <- NA

clean_data <- data[, c("Recommended_Customer_Price",          # Y: giá
                       "nb_of_Cores",                         # số nhân
                       "Processor_Base_Frequency",            # xung nhịp cơ bản
                       "Cache",                               # bộ nhớ đệm
                       "Lithography",                         # tiến trình (nm)
                       "Vertical_Segment",                    # phân khúc
                       "Intel_Hyper_Threading_Technology_")]  # có/không phân luồng
View(clean_data)
