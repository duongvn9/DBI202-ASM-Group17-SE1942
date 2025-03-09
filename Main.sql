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
