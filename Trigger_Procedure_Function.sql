﻿--1. Trigger kiểm tra CheckInDate phải sau BookingDate
CREATE TRIGGER trg_CheckInDate 
ON BOOKING
AFTER INSERT
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE CheckInDate < BookingDate
    )
    BEGIN
        RAISERROR ('Check-in date must be on or after booking date', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO
--2. Trigger kiểm tra CheckOutDate phải sau CheckInDate
CREATE TRIGGER trg_CheckOutDate 
ON BOOKING
AFTER INSERT, UPDATE
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE CheckOutDate < CheckInDate
    )
    BEGIN
        RAISERROR ('Check-out date must be on after check-in date', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO
--3. Trigger kiểm tra thanh toán không vượt quá số tiền booking
CREATE TRIGGER trg_ValidatePayment 
ON PAYMENT
AFTER INSERT
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN BOOKING b ON i.BookingID = b.BookingID
        JOIN ROOM r ON b.RoomID = r.RoomID
        WHERE i.Amount > (r.RoomPrice * DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate))
    )
    BEGIN
        RAISERROR ('Payment amount exceeds total room price', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;
GO
--Fix
ALTER TRIGGER trg_ValidatePayment 
ON PAYMENT
AFTER INSERT
AS 
BEGIN 
    DECLARE @BookingID INT;
    DECLARE @Amount DECIMAL(10,2);
    DECLARE @TotalRoomPrice DECIMAL(10,2);
    DECLARE @Overpayment DECIMAL(10,2);

    -- Lấy thông tin từ inserted
    SELECT 
        @BookingID = i.BookingID,
        @Amount = i.Amount
    FROM inserted i;

    -- Tính tổng tiền phòng
    SELECT @TotalRoomPrice = 
        CASE 
            WHEN b.CheckInDate = b.CheckOutDate THEN r.RoomPrice * 1
            ELSE r.RoomPrice * DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate)
        END
    FROM BOOKING b
    JOIN ROOM r ON b.RoomID = r.RoomID
    WHERE b.BookingID = @BookingID;

    -- Tính số tiền thừa (nếu có)
    SET @Overpayment = CASE 
        WHEN @Amount > @TotalRoomPrice THEN @Amount - @TotalRoomPrice 
        ELSE 0 
    END;

    -- Báo thông tin số tiền thừa (nếu có)
    IF @Overpayment > 0
    BEGIN
        DECLARE @Message NVARCHAR(100);
        SET @Message = 'Overpayment detected: ' + CAST(@Overpayment AS NVARCHAR(20)) + ' VND';
        RAISERROR (@Message, 10, 1); -- Mức 10 là thông báo, không rollback
    END;
END;
GO

--4. Procedure tạo booking mới
CREATE PROCEDURE CreateBooking
	--Customer
	@Name VARCHAR(100),
	@DOB DATE,
	@Email VARCHAR(100),
	@PhoneNumber VARCHAR(15),
	--Room
	@CustomerID INT,
    @RoomID INT,
    @BookingDate DATE,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
	INSERT INTO CUSTOMER (Name, DOB, Email, PhoneNumber)
	VALUES (@Name, @DOB, @Email, @PhoneNumber)

    INSERT INTO BOOKING (CustomerID, RoomID, BookingDate, CheckInDate, CheckOutDate, BookingStatus)
    VALUES (@CustomerID, @RoomID, @BookingDate, @CheckInDate, @CheckOutDate, 'Pending');
END;
GO
--5. Procedure xử lý thanh toán
CREATE PROCEDURE ProcessPayment
    @BookingID INT,
    @Amount DECIMAL(10,2),
    @PaymentMethod VARCHAR(50)
AS
BEGIN
    INSERT INTO PAYMENT (BookingID, PaymentDate, Amount, PaymentMethod, PaymentStatus)
    VALUES (@BookingID, GETDATE(), @Amount, @PaymentMethod, 'Paid');
END;
GO
--6. Function tính tổng tiền booking
CREATE FUNCTION GetTotalAmount (@BookingID INT) 
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10,2);
    SELECT @TotalAmount = SUM(r.RoomPrice * DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate))
    FROM BOOKING b
    JOIN ROOM r ON b.RoomID = r.RoomID
    WHERE b.BookingID = @BookingID;
    RETURN ISNULL(@TotalAmount, 0);
END;
GO
--Fix
ALTER FUNCTION GetTotalAmount (@BookingID INT) 
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10,2);
    DECLARE @CheckInDate DATE;
    DECLARE @CheckOutDate DATE;
    DECLARE @RoomPrice DECIMAL(10,2);

    -- Lấy thông tin từ BOOKING và ROOM
    SELECT 
        @CheckInDate = b.CheckInDate,
        @CheckOutDate = b.CheckOutDate,
        @RoomPrice = r.RoomPrice
    FROM BOOKING b
    JOIN ROOM r ON b.RoomID = r.RoomID
    WHERE b.BookingID = @BookingID;

    -- Tính tổng tiền
    SET @TotalAmount = 
        CASE 
            WHEN @CheckInDate = @CheckOutDate THEN @RoomPrice * 1  -- Cùng ngày: Tính 1 ngày
            ELSE @RoomPrice * DATEDIFF(DAY, @CheckInDate, @CheckOutDate)  -- Khác ngày: Tính như cũ
        END;

    RETURN ISNULL(@TotalAmount, 0);
END;
GO

--7. Function kiểm tra phòng trống
CREATE FUNCTION IsRoomAvailable (@RoomID INT) 
RETURNS BIT
AS
BEGIN
    DECLARE @status VARCHAR(20);
    SELECT @status = RoomStatus 
    FROM ROOM 
    WHERE RoomID = @RoomID;
    RETURN CASE WHEN @status = 'Available' THEN 1 ELSE 0 END;
END;
GO