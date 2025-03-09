SELECT * FROM CUSTOMER
SELECT * FROM ROOM
SELECT * FROM SERVICE
SELECT * FROM BOOKING
SELECT * FROM PAYMENT
SELECT * FROM STAFF
SELECT * FROM ROOM_SERVICE

--Kiểm tra phòng trống
SELECT r.RoomID, r.RoomType, r.RoomPrice, r.RoomStatus
FROM ROOM r
WHERE r.RoomStatus = 'Available'
AND NOT EXISTS (
    SELECT 1 
    FROM BOOKING b 
    WHERE b.RoomID = r.RoomID 
    AND b.BookingStatus IN ('Confirmed', 'Checked-in')
    AND (
        (b.CheckInDate <= '2025-03-15' AND b.CheckOutDate >= '2025-03-10')
    )
)
--Deluxe
SELECT *
FROM ROOM
WHERE RoomType = 'Deluxe'

--2. Truy vấn danh sách booking của khách hàng
SELECT 
    b.BookingID, 
    c.Name AS CustomerName, 
    r.RoomType, 
    b.BookingDate, 
    b.CheckInDate, 
    b.CheckOutDate, 
    b.BookingStatus
FROM BOOKING b
JOIN CUSTOMER c ON b.CustomerID = c.CustomerID
JOIN ROOM r ON b.RoomID = r.RoomID
WHERE c.Email = 'an.nguyen@gmail.com'

--3. Truy vấn tổng tiền thanh toán của booking
SELECT 
    b.BookingID,
    r.RoomPrice * DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) AS RoomCost,
    ISNULL(SUM(s.ServicePrice), 0) AS ServiceCost,
    r.RoomPrice * DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) + ISNULL(SUM(s.ServicePrice), 0) AS TotalCost
FROM BOOKING b
JOIN ROOM r ON b.RoomID = r.RoomID
LEFT JOIN ROOM_SERVICE rs ON rs.RoomID = b.RoomID
LEFT JOIN SERVICE s ON rs.ServiceID = s.ServiceID
WHERE b.BookingID = 1
GROUP BY b.BookingID, r.RoomPrice, b.CheckInDate, b.CheckOutDate;

--4. Truy vấn trạng thái thanh toán của một BookingID
SELECT 
    b.BookingID, 
    c.Name AS CustomerName, 
    p.PaymentDate, 
    p.Amount, 
    p.PaymentMethod, 
    p.PaymentStatus
FROM BOOKING b
JOIN CUSTOMER c ON b.CustomerID = c.CustomerID
LEFT JOIN PAYMENT p ON b.BookingID = p.BookingID
WHERE b.BookingID = 2;

--5. Truy vấn danh sách phòng cần bảo trì
SELECT RoomID, RoomType, RoomPrice
FROM ROOM
WHERE RoomStatus = 'Maintenance';

--6. Truy vấn doanh thu theo khoảng thời gian
SELECT 
    SUM(p.Amount) AS TotalRevenue,
    COUNT(DISTINCT p.BookingID) AS PaidBookings
FROM PAYMENT p
WHERE p.PaymentStatus = 'Paid'
AND p.PaymentDate BETWEEN '2025-03-01' AND '2025-03-31';

--7. Truy vấn dịch vụ được sử dụng nhiều nhất
SELECT 
    s.ServiceName, 
    s.ServicePrice, 
    COUNT(rs.ServiceID) AS UsageCount
FROM SERVICE s
JOIN ROOM_SERVICE rs ON s.ServiceID = rs.ServiceID
GROUP BY s.ServiceName, s.ServicePrice
ORDER BY UsageCount DESC;

--8. Truy vấn khách hàng đặt phòng nhiều nhất
SELECT 
    c.CustomerID, 
    c.Name, 
    c.Email, 
    COUNT(b.BookingID) AS BookingCount
FROM CUSTOMER c
JOIN BOOKING b ON c.CustomerID = b.CustomerID
GROUP BY c.CustomerID, c.Name, c.Email
ORDER BY BookingCount DESC;


--9. Truy vấn nhân viên phụ trách dịch vụ
SELECT 
    st.StaffName, 
    st.StaffDepartment, 
    s.ServiceName, 
    s.ServiceDescription
FROM STAFF st
LEFT JOIN SERVICE s ON st.ServiceID = s.ServiceID
WHERE st.StaffDepartment = 'Housekeeping';

--10. Truy vấn lịch sử booking của một phòng
SELECT 
    b.BookingID, 
    c.Name AS CustomerName, 
    b.CheckInDate, 
    b.CheckOutDate, 
    b.BookingStatus
FROM BOOKING b
JOIN CUSTOMER c ON b.CustomerID = c.CustomerID
WHERE b.RoomID = 1
ORDER BY b.CheckInDate;


--11. Truy vấn phòng sắp hết thời gian booking
SELECT 
    b.BookingID, 
    r.RoomID, 
    r.RoomType, 
    c.Name AS CustomerName, 
    b.CheckOutDate, 
    b.BookingStatus
FROM BOOKING b
JOIN ROOM r ON b.RoomID = r.RoomID
JOIN CUSTOMER c ON b.CustomerID = c.CustomerID
WHERE b.CheckOutDate BETWEEN GETDATE() AND DATEADD(DAY, 1, GETDATE())
AND b.BookingStatus IN ('Checked-in', 'Confirmed');

--12. Truy vấn số ngày trung bình khách ở lại
SELECT 
    AVG(DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate)) AS AvgStayDays
FROM BOOKING b
WHERE b.BookingStatus IN ('Checked-in', 'Confirmed');

--13. Truy vấn phòng chưa được thanh toán
SELECT 
    b.BookingID, 
    c.Name AS CustomerName, 
    r.RoomType, 
    b.CheckInDate, 
    b.CheckOutDate
FROM BOOKING b
JOIN CUSTOMER c ON b.CustomerID = c.CustomerID
JOIN ROOM r ON b.RoomID = r.RoomID
LEFT JOIN PAYMENT p ON b.BookingID = p.BookingID
WHERE b.BookingStatus = 'Checked-in'
AND (p.PaymentStatus IS NULL OR p.PaymentStatus != 'Paid');

--14. Truy vấn doanh thu theo loại phòng
SELECT 
    r.RoomType, 
    COUNT(b.BookingID) AS BookingCount, 
    SUM(r.RoomPrice * DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate)) AS TotalRevenue
FROM ROOM r
JOIN BOOKING b ON r.RoomID = b.RoomID
JOIN PAYMENT p ON b.BookingID = p.BookingID
WHERE p.PaymentStatus = 'Paid'
GROUP BY r.RoomType
ORDER BY TotalRevenue DESC;

--15. Truy vấn khách hàng hủy booking nhiều nhất
SELECT 
    c.CustomerID, 
    c.Name, 
    c.Email, 
    COUNT(b.BookingID) AS CancelledBookings
FROM CUSTOMER c
JOIN BOOKING b ON c.CustomerID = b.CustomerID
WHERE b.BookingStatus = 'Cancelled'
GROUP BY c.CustomerID, c.Name, c.Email
ORDER BY CancelledBookings DESC;

--16. Truy vấn lịch sử sử dụng dịch vụ của một khách hàng
SELECT 
    c.Name AS CustomerName, 
    s.ServiceName, 
    s.ServicePrice, 
    COUNT(rs.ServiceID) AS UsageCount
FROM CUSTOMER c
JOIN BOOKING b ON c.CustomerID = b.CustomerID
JOIN ROOM_SERVICE rs ON b.RoomID = rs.RoomID
JOIN SERVICE s ON rs.ServiceID = s.ServiceID
WHERE c.CustomerID = 1
GROUP BY c.Name, s.ServiceName, s.ServicePrice;


--17. Truy vấn tỷ lệ lấp đầy phòng
--Tính tỷ lệ phòng được sử dụng từ 10/03/2025 đến 15/03/2025 so với tổng số phòng.

SELECT 
    CAST(COUNT(CASE WHEN b.BookingStatus IN ('Checked-in', 'Confirmed') THEN 1 END) AS FLOAT) / 
    (SELECT COUNT(*) FROM ROOM) * 100 AS OccupancyRate
FROM BOOKING b
WHERE b.CheckInDate <= '2025-03-15' 
AND b.CheckOutDate >= '2025-03-10';

--18. Truy vấn nhân viên bận rộn nhất
SELECT 
    st.StaffName, 
    st.StaffDepartment, 
    COUNT(st.ServiceID) AS ServiceCount
FROM STAFF st
WHERE st.ServiceID IS NOT NULL
GROUP BY st.StaffName, st.StaffDepartment
ORDER BY ServiceCount DESC;

--19. Truy vấn booking gần đây nhất
SELECT TOP 5
    b.BookingID, 
    c.Name AS CustomerName, 
    r.RoomType, 
    b.BookingDate, 
    b.CheckInDate, 
    b.CheckOutDate
FROM BOOKING b
JOIN CUSTOMER c ON b.CustomerID = c.CustomerID
JOIN ROOM r ON b.RoomID = r.RoomID
ORDER BY b.BookingDate DESC;

--20. Truy vấn phòng có doanh thu thấp nhất
SELECT 
    r.RoomID, 
    r.RoomType, 
    r.RoomPrice, 
    ISNULL(SUM(p.Amount), 0) AS TotalRevenue
FROM ROOM r
LEFT JOIN BOOKING b ON r.RoomID = b.RoomID
LEFT JOIN PAYMENT p ON b.BookingID = p.BookingID AND p.PaymentStatus = 'Paid'
GROUP BY r.RoomID, r.RoomType, r.RoomPrice
ORDER BY TotalRevenue ASC;
