--1. Trigger kiểm tra CheckInDate phải sau BookingDate
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
        THROW 50001, 'Check-in date must be on or after booking date', 1;
        -- Không ROLLBACK, để procedure xử lý
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
        THROW 50002, 'Check-out date must be on or after check-in date', 1;
        -- Không ROLLBACK, để procedure xử lý
    END;
END;
GO
--3. Trigger kiểm tra thanh toán không vượt quá số tiền booking
CREATE TRIGGER trg_ValidatePayment 
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
CREATE PROCEDURE CreateNewBooking
	@Name VARCHAR(100),
	@DOB DATE,
	@Email VARCHAR(100),
	@PhoneNumber VARCHAR(15),
	@RoomID INT,
	@BookingDate DATE,
	@CheckInDate DATE,
	@CheckOutDate DATE
AS
BEGIN
    SET NOCOUNT ON; -- Ngăn thông báo "rows affected" gây nhầm lẫn
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Thêm khách hàng
        INSERT INTO CUSTOMER (Name, DOB, Email, PhoneNumber)
        VALUES (@Name, @DOB, @Email, @PhoneNumber);
        DECLARE @CustomerID INT = SCOPE_IDENTITY();

        -- Kiểm tra RoomID
        IF NOT EXISTS (SELECT 1 FROM ROOM WHERE RoomID = @RoomID)
            THROW 50002, 'RoomID does not exist.', 1;

        -- Thêm booking (trigger sẽ kiểm tra)
        INSERT INTO BOOKING (CustomerID, RoomID, BookingDate, CheckInDate, CheckOutDate, BookingStatus)
        VALUES (@CustomerID, @RoomID, @BookingDate, @CheckInDate, @CheckOutDate, 'Pending');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Chỉ rollback nếu giao dịch còn tồn tại
        WHILE @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW; -- Ném lỗi ra ngoài
    END CATCH;
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