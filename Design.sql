-- Tạo bảng CUSTOMER
CREATE TABLE CUSTOMER (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL CHECK (Name NOT LIKE '%[^A-Za-z ]%'),
    DOB DATE NOT NULL CHECK (DOB <= GETDATE()),
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(15) NOT NULL UNIQUE CHECK (PhoneNumber NOT LIKE '%[^0-9]%')
);

-- Tạo bảng ROOM
CREATE TABLE ROOM (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomType VARCHAR(20) NOT NULL CHECK (RoomType IN ('Single', 'Double', 'Suite', 'Deluxe')),
    RoomPrice DECIMAL(10,2) NOT NULL CHECK (RoomPrice > 0),
    RoomStatus VARCHAR(20) NOT NULL CHECK (RoomStatus IN ('Available', 'Occupied', 'Maintenance'))
);

-- Tạo bảng BOOKING
CREATE TABLE BOOKING (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    RoomID INT NOT NULL,
    BookingDate DATE NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    BookingStatus VARCHAR(20) NOT NULL CHECK (BookingStatus IN ('Pending', 'Confirmed', 'Checked-in', 'Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE CASCADE
);

-- Tạo bảng PAYMENT
CREATE TABLE PAYMENT (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentMethod VARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Bank Transfer')),
    PaymentStatus VARCHAR(20) NOT NULL CHECK (PaymentStatus IN ('Paid', 'Pending', 'Failed')),
    FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE CASCADE
);

-- Tạo bảng SERVICE
CREATE TABLE SERVICE (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceName VARCHAR(100) NOT NULL UNIQUE CHECK (ServiceName NOT LIKE '%[^A-Za-z ]%'),
    ServicePrice DECIMAL(10,2) NOT NULL CHECK (ServicePrice >= 0),
    ServiceDescription VARCHAR(255) NULL
);

-- Tạo bảng STAFF
CREATE TABLE STAFF (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    StaffName VARCHAR(100) NOT NULL CHECK (StaffName NOT LIKE '%[^A-Za-z ]%'),
    StaffDepartment VARCHAR(50) NOT NULL CHECK (StaffDepartment IN ('Housekeeping', 'Reception', 'Maintenance', 'Catering')),
    ServiceID INT,
    FOREIGN KEY (ServiceID) REFERENCES SERVICE(ServiceID) ON DELETE SET NULL
);

-- Tạo bảng ROOM_SERVICE
CREATE TABLE ROOM_SERVICE (
    RoomID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (RoomID, ServiceID),
    FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES SERVICE(ServiceID) ON DELETE CASCADE
);

-- Trigger kiểm tra CheckInDate phải sau BookingDate
CREATE TRIGGER trg_CheckInDate 
ON BOOKING
AFTER INSERT
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 FROM inserted WHERE CheckInDate < BookingDate
    )
    BEGIN
        RAISERROR ('Check-in date must be after booking date', 16, 1);
        ROLLBACK;
    END;
END;

-- Trigger kiểm tra CheckOutDate phải sau CheckInDate
CREATE TRIGGER trg_CheckOutDate 
ON BOOKING
AFTER INSERT, UPDATE
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 FROM inserted WHERE CheckOutDate <= CheckInDate
    )
    BEGIN
        RAISERROR ('Check-out date must be after check-in date', 16, 1);
        ROLLBACK;
    END;
END;

-- Trigger kiểm tra thanh toán không vượt quá số tiền booking
CREATE TRIGGER trg_ValidatePayment 
ON PAYMENT
AFTER INSERT
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN BOOKING b ON i.BookingID = b.BookingID
        JOIN ROOM r ON b.RoomID = r.RoomID
        WHERE i.Amount > r.RoomPrice
    )
    BEGIN
        RAISERROR ('Payment amount exceeds total room price', 16, 1);
        ROLLBACK;
    END;
END;

-- Procedure tạo booking mới
CREATE PROCEDURE CreateBooking
    @CustomerID INT,
    @RoomID INT,
    @BookingDate DATE,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    INSERT INTO BOOKING (CustomerID, RoomID, BookingDate, CheckInDate, CheckOutDate, BookingStatus)
    VALUES (@CustomerID, @RoomID, @BookingDate, @CheckInDate, @CheckOutDate, 'Pending');
END;

-- Procedure xử lý thanh toán
CREATE PROCEDURE ProcessPayment
    @BookingID INT,
    @Amount DECIMAL(10,2),
    @PaymentMethod VARCHAR(50)
AS
BEGIN
    INSERT INTO PAYMENT (BookingID, PaymentDate, Amount, PaymentMethod, PaymentStatus)
    VALUES (@BookingID, GETDATE(), @Amount, @PaymentMethod, 'Paid');
END;

-- Function tính tổng tiền booking
CREATE FUNCTION GetTotalAmount(@BookingID INT) 
RETURNS TABLE
AS
RETURN (
    SELECT SUM(RoomPrice) AS TotalAmount
    FROM BOOKING b
    JOIN ROOM r ON b.RoomID = r.RoomID
    WHERE b.BookingID = @BookingID
);

-- Function kiểm tra phòng trống
CREATE FUNCTION IsRoomAvailable(@RoomID INT) 
RETURNS BIT
AS
BEGIN
    DECLARE @status VARCHAR(20);
    SELECT @status = RoomStatus FROM ROOM WHERE RoomID = @RoomID;
    RETURN CASE WHEN @status = 'Available' THEN 1 ELSE 0 END;
END;
