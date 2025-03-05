﻿-- Insert CUSTOMER
INSERT INTO CUSTOMER (Name, DOB, Email, PhoneNumber) VALUES
('Nguyen Van An', '1990-05-15', 'an.nguyen@gmail.com', '0905123456'),
('Tran Thi Bich', '1985-12-20', 'bich.tran@yahoo.com', '0918765432'),
('Le Hoang Chuong', '1995-03-10', 'chuong.le@hotmail.com', '0932112233'),
('Pham Minh Duc', '2000-07-25', 'duc.pham@gmail.com', '0987654321'),
('Hoang Thi Em', '1992-09-30', 'em.hoang@outlook.com', '0945678901'),
('Vo Van Phuc', '1988-11-11', 'phuc.vo@gmail.com', '0923456789'),
('Bui Thi Lan', '1993-04-22', 'lan.bui@yahoo.com', '0971234567'),
('Dang Minh Khoa', '1997-06-30', 'khoa.dang@hotmail.com', '0912345678'),
('Ngo Thi Mai', '1980-08-15', 'mai.ngo@outlook.com', '0967891234'),
('Trinh Van Long', '1991-01-05', 'long.trinh@gmail.com', '0934567890'),
('Do Thi Hoa', '1987-03-17', 'hoa.do@yahoo.com', '0909876543'),
('Phan Van Hieu', '1994-12-25', 'hieu.phan@hotmail.com', '0941234567'),
('Ly Thi Ngoc', '1996-07-10', 'ngoc.ly@gmail.com', '0956789012'),
('Vu Minh Tam', '1989-09-09', 'tam.vu@outlook.com', '0926789012'),
('Nguyen Thi Kim', '1998-02-14', 'kim.nguyen@yahoo.com', '0981234567'),
('Tran Van Bao', '1986-10-20', 'bao.tran@gmail.com', '0913456789'),
('Le Thi Thu', '1999-05-05', 'thu.le@hotmail.com', '0978901234'),
('Pham Van Tuan', '1990-11-30', 'tuan.pham@outlook.com', '0936789012'),
('Hoang Minh Quan', '1984-08-08', 'quan.hoang@gmail.com', '0961234567'),
('Bui Van Hung', '1995-12-15', 'hung.bui@yahoo.com', '0947891234');

-- Insert ROOM
INSERT INTO ROOM (RoomType, RoomPrice, RoomStatus) VALUES
('Single', 500000.00, 'Available'),
('Double', 800000.00, 'Occupied'),
('Suite', 1500000.00, 'Available'),
('Deluxe', 2000000.00, 'Maintenance'),
('Single', 550000.00, 'Available'),
('Double', 850000.00, 'Occupied'),
('Suite', 1600000.00, 'Available'),
('Deluxe', 2100000.00, 'Maintenance'),
('Single', 520000.00, 'Available'),
('Double', 870000.00, 'Occupied'),
('Suite', 1550000.00, 'Available'),
('Single', 530000.00, 'Available'),
('Double', 820000.00, 'Occupied'),
('Deluxe', 2200000.00, 'Maintenance'),
('Suite', 1650000.00, 'Available'),
('Single', 510000.00, 'Available'),
('Double', 830000.00, 'Occupied'),
('Suite', 1700000.00, 'Available'),
('Deluxe', 2300000.00, 'Maintenance'),
('Single', 540000.00, 'Available');

-- Insert SERVICE
INSERT INTO SERVICE (ServiceName, ServicePrice, ServiceDescription) VALUES
('Laundry', 50000.00, N'Giặt là quần áo'),
('Breakfast', 100000.00, N'Bữa sáng tự chọn'),
('Spa', 500000.00, N'Dịch vụ massage thư giãn'),
('Airport Shuttle', 200000.00, N'Đưa đón sân bay'),
('Room Cleaning', 0.00, N'Dọn phòng miễn phí'),
('Dinner', 150000.00, N'Bữa tối cao cấp'),
('Gym', 100000.00, N'Phòng tập thể dục'),
('Pool Access', 80000.00, N'Sử dụng hồ bơi'),
('Minibar', 200000.00, N'Đồ uống trong phòng'),
('Late Checkout', 300000.00, N'Trả phòng muộn'),
('WiFi Premium', 50000.00, N'Internet tốc độ cao'),
('Parking', 70000.00, N'Gửi xe tại khách sạn'),
('City Tour', 400000.00, N'Tham quan thành phố'),
('Massage', 450000.00, N'Massage toàn thân'),
('Sauna', 300000.00, N'Xông hơi thư giãn'),
('Laundry Express', 100000.00, N'Giặt là nhanh'),
('Breakfast in Room', 120000.00, N'Bữa sáng tại phòng'),
('Bike Rental', 150000.00, N'Thuê xe đạp'),
('Concierge', 0.00, N'Dịch vụ hỗ trợ khách'),
('Pet Care', 250000.00, N'Chăm sóc thú cưng');

-- Insert BOOKING
INSERT INTO BOOKING (CustomerID, RoomID, BookingDate, CheckInDate, CheckOutDate, BookingStatus) VALUES
(1, 1, '2025-03-01', '2025-03-10', '2025-03-12', 'Confirmed'),
(2, 2, '2025-03-02', '2025-03-05', '2025-03-08', 'Checked-in'),
(3, 3, '2025-03-03', '2025-03-15', '2025-03-20', 'Pending'),
(4, 5, '2025-03-04', '2025-03-06', '2025-03-07', 'Cancelled'),
(5, 1, '2025-03-05', '2025-03-08', '2025-03-10', 'Confirmed'),
(6, 6, '2025-03-06', '2025-03-12', '2025-03-15', 'Checked-in'),
(7, 7, '2025-03-07', '2025-03-20', '2025-03-25', 'Pending'),
(8, 9, '2025-03-08', '2025-03-09', '2025-03-11', 'Confirmed'),
(9, 10, '2025-03-09', '2025-03-14', '2025-03-17', 'Checked-in'),
(10, 11, '2025-03-10', '2025-03-18', '2025-03-22', 'Pending'),
(11, 12, '2025-03-11', '2025-03-13', '2025-03-15', 'Confirmed'),
(12, 13, '2025-03-12', '2025-03-16', '2025-03-19', 'Checked-in'),
(13, 15, '2025-03-13', '2025-03-20', '2025-03-25', 'Pending'),
(14, 16, '2025-03-14', '2025-03-17', '2025-03-19', 'Confirmed'),
(15, 17, '2025-03-15', '2025-03-21', '2025-03-24', 'Checked-in'),
(16, 18, '2025-03-16', '2025-03-25', '2025-03-30', 'Pending'),
(17, 19, '2025-03-17', '2025-03-19', '2025-03-21', 'Confirmed'),
(18, 20, '2025-03-18', '2025-03-22', '2025-03-25', 'Checked-in'),
(19, 1, '2025-03-19', '2025-03-26', '2025-03-28', 'Pending'),
(20, 3, '2025-03-20', '2025-03-27', '2025-03-30', 'Confirmed');

-- Insert PAYMENT
INSERT INTO PAYMENT (BookingID, PaymentDate, Amount, PaymentMethod, PaymentStatus) VALUES
(1, '2025-03-02', 1000000.00, 'Credit Card', 'Paid'),
(2, '2025-03-03', 2400000.00, 'Cash', 'Paid'),
(3, '2025-03-04', 7500000.00, 'Bank Transfer', 'Pending'),
(4, '2025-03-05', 550000.00, 'Credit Card', 'Failed'),
(5, '2025-03-06', 1000000.00, 'Cash', 'Paid'),
(6, '2025-03-07', 2550000.00, 'Credit Card', 'Paid'),
(7, '2025-03-08', 8000000.00, 'Bank Transfer', 'Pending'),
(8, '2025-03-09', 1040000.00, 'Cash', 'Paid'),
(9, '2025-03-10', 2610000.00, 'Credit Card', 'Paid'),
(10, '2025-03-11', 6200000.00, 'Bank Transfer', 'Pending'),
(11, '2025-03-12', 1060000.00, 'Cash', 'Paid'),
(12, '2025-03-13', 2460000.00, 'Credit Card', 'Paid'),
(13, '2025-03-14', 8250000.00, 'Bank Transfer', 'Pending'),
(14, '2025-03-15', 1020000.00, 'Cash', 'Paid'),
(15, '2025-03-16', 2490000.00, 'Credit Card', 'Paid'),
(16, '2025-03-17', 8500000.00, 'Bank Transfer', 'Pending'),
(17, '2025-03-18', 4600000.00, 'Cash', 'Paid'),
(18, '2025-03-19', 1620000.00, 'Credit Card', 'Paid'),
(19, '2025-03-20', 1000000.00, 'Bank Transfer', 'Pending'),
(20, '2025-03-21', 4500000.00, 'Cash', 'Paid');

-- Insert STAFF
INSERT INTO STAFF (StaffName, StaffDepartment, ServiceID) VALUES
('Nguyen Thi Hoa', 'Housekeeping', 5),
('Tran Van Khanh', 'Reception', NULL),
('Le Minh Long', 'Maintenance', NULL),
('Pham Thi Mai', 'Catering', 2),
('Hoang Van Nam', 'Housekeeping', 5),
('Vo Thi Lan', 'Housekeeping', 1),
('Bui Van Phu', 'Reception', NULL),
('Dang Thi Ngoc', 'Catering', 6),
('Ngo Van Hung', 'Maintenance', NULL),
('Trinh Thi Thu', 'Housekeeping', 16),
('Do Van Khoa', 'Reception', NULL),
('Phan Thi Kim', 'Catering', 17),
('Ly Van Bao', 'Maintenance', NULL),
('Vu Thi Hien', 'Housekeeping', 5),
('Nguyen Van Tuan', 'Reception', NULL),
('Tran Thi Ha', 'Catering', 2),
('Le Van Duc', 'Maintenance', NULL),
('Pham Thi Linh', 'Housekeeping', 1),
('Hoang Van Quan', 'Reception', NULL),
('Bui Thi Anh', 'Catering', 6);

-- Insert ROOM_SERVICE
INSERT INTO ROOM_SERVICE (RoomID, ServiceID) VALUES
(1, 1),
(1, 5),
(2, 2),
(3, 3),
(5, 4),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);