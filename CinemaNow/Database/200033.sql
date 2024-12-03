CREATE DATABASE IB200033
GO
USE IB200033

CREATE TABLE [User] (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Email VARCHAR(100),
    Username VARCHAR(50),
    PasswordSalt NVARCHAR(128),
    PasswordHash NVARCHAR(128),
    Image VARBINARY(MAX)
);

CREATE TABLE Role (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE UserRole (
    UserID INT,
    RoleID INT,
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE,
    FOREIGN KEY (RoleID) REFERENCES Role(ID) ON DELETE CASCADE,
    PRIMARY KEY (UserID, RoleID)
);

CREATE TABLE Movie (
    ID INT PRIMARY KEY IDENTITY,
    Title VARCHAR(100),
    Duration INT,
    Synopsis VARCHAR(MAX),
    Image VARBINARY(MAX)
);

CREATE TABLE Genre (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE MovieGenre (
    MovieID INT,
    GenreID INT,
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
    FOREIGN KEY (GenreID) REFERENCES Genre(ID) ON DELETE CASCADE,
    PRIMARY KEY (MovieID, GenreID)
);

CREATE TABLE Actor (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Image VARBINARY(MAX)
);

CREATE TABLE MovieActor (
    MovieID INT,
    ActorID INT,
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
    FOREIGN KEY (ActorID) REFERENCES Actor(ID) ON DELETE CASCADE,
    PRIMARY KEY (MovieID, ActorID)
);

CREATE TABLE Hall (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE ViewMode (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE Screening (
    ID INT PRIMARY KEY IDENTITY,
    MovieID INT,
	HallID INT,
	ViewModeID INT,
    DateTime DATETIME,
    Price DECIMAL(10,2),
    StateMachine VARCHAR(50),
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
	FOREIGN KEY (HallID) REFERENCES Hall(ID) ON DELETE CASCADE,
    FOREIGN KEY (ViewModeID) REFERENCES ViewMode(ID) ON DELETE CASCADE
);

CREATE TABLE Seat (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(10)
);

CREATE TABLE ScreeningSeat (
    ScreeningID INT,
    SeatID INT,
    IsReserved BIT DEFAULT 0,
    FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(ID) ON DELETE CASCADE,
    PRIMARY KEY (ScreeningID, SeatID)
);

CREATE TABLE Payment (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    Provider VARCHAR(50),
    TransactionID VARCHAR(255),
    Amount DECIMAL(10,2),
    DateTime DATETIME,
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE
);

CREATE TABLE Reservation (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    ScreeningID INT,
    DateTime DATETIME,
    NumberOfTickets INT,
    TotalPrice DECIMAL(10,2),
	PaymentID INT NULL,
	PaymentType VARCHAR(50) DEFAULT 'Cash',
	QRCodeBase64 NVARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE NO ACTION,
    FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE CASCADE,
	FOREIGN KEY (PaymentID) REFERENCES Payment(ID) ON DELETE SET NULL
);

CREATE TABLE ReservationSeat (
    ReservationID INT,
    SeatID INT,
	ReservedAt DATETIME,
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ID) ON DELETE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(ID) ON DELETE CASCADE,
    PRIMARY KEY (ReservationID, SeatID)
);

CREATE TABLE Rating (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    MovieID INT,
    Value INT,
    Comment VARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE
);

INSERT INTO [User] (Name, Surname, Email, Username, PasswordSalt, PasswordHash, Image)
VALUES 
('Emma', 'Johnson', 'emma.j@example.com', 'emma_j', 'abcdefg12345', '$2y$10$uFj8G3cSJazj5VpShYYGYODSQ8xVOlBghxOGU5iGBt7mXc/Q8qM12', NULL),
('Michael', 'Smith', 'michael.s@example.com', 'michael_s', 'qwerty12345', '$2y$10$jHWmzGdZdfA4oUGZ9Efjzuj8sGp0fV9YzKyZUB41VTH4v2QGw3L/q', NULL),
('Olivia', 'Williams', 'olivia.w@example.com', 'olivia_w', '1234567890', '$2y$10$zJGeJDEYIlyuk3vm.V6EyO0RFVdoXvXy5F/SJxXTntMP0JArz5SdC', NULL),
('Ava', 'Brown', 'ava.brown@example.com', 'ava_b', 'passwordSalt1', 'passwordHash1', NULL),
('Liam', 'Davis', 'liam.davis@example.com', 'liam_d', 'passwordSalt2', 'passwordHash2', NULL),
('Sophia', 'Miller', 'sophia.miller@example.com', 'sophia_m', 'passwordSalt3', 'passwordHash3', NULL),
('Noah', 'Wilson', 'noah.wilson@example.com', 'noah_w', 'passwordSalt4', 'passwordHash4', NULL),
('Isabella', 'Moore', 'isabella.moore@example.com', 'isabella_m', 'passwordSalt5', 'passwordHash5', NULL),
('Ethan', 'Taylor', 'ethan.taylor@example.com', 'ethan_t', 'passwordSalt6', 'passwordHash6', NULL),
('Mia', 'Anderson', 'mia.anderson@example.com', 'mia_a', 'passwordSalt7', 'passwordHash7', NULL);

INSERT INTO Role (Name)
VALUES 
('User'),
('Admin');

INSERT INTO UserRole (UserID, RoleID)
VALUES 
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 2),
(10, 2);

INSERT INTO Movie (Title, Duration, Synopsis, Image)
VALUES 
('The Shawshank Redemption', 142, 'A banker convicted of uxoricide forms a friendship over a quarter century with a hardened convict, while maintaining his innocence and trying to remain hopeful through simple compassion.', NULL),
('The Godfather', 175, 'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.', NULL),
('The Dark Knight', 152, 'When a menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman, James Gordon and Harvey Dent must work together to put an end to the madness.', NULL),
('Inception', 148, 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O., but his tragic past may doom the project and his team to disaster.', NULL),
('The Matrix', 136, 'When a beautiful stranger leads computer hacker Neo to a forbidding underworld, he discovers the shocking truth--the life he knows is the elaborate deception of an evil cyber-intelligence.', NULL),
('Fight Club', 139, 'An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into much more.', NULL),
('Pulp Fiction', 154, 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.', NULL),
('Forrest Gump', 142, 'The history of the United States from the 1950s to the ''70s unfolds from the perspective of an Alabama man with an IQ of 75, who yearns to be reunited with his childhood sweetheart.', NULL),
('The Lord of the Rings: The Return of the King', 201, 'Gandalf and Aragorn lead the World of Men against Sauron''s army to draw his gaze from Frodo and Sam as they approach Mount Doom with the One Ring.', NULL),
('The Silence of the Lambs', 118, 'A young F.B.I. cadet must receive the help of an incarcerated and manipulative cannibal killer to help catch another serial killer, a madman who skins his victims.', NULL),
('10 Things I Hate About You', 97, 'A high-school boy, Cameron, cannot date Bianca until her anti-social older sister, Kat, has a boyfriend. So, Cameron pays a mysterious boy, Patrick, to charm Kat.', NULL),
('Titanic', 194, 'A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.', NULL),
('Shutter Island', 138, 'Teddy Daniels and Chuck Aule, two US marshals, are sent to an asylum on a remote island in order to investigate the disappearance of a patient, where Teddy uncovers a shocking truth about the place.', NULL),
('The Great Gatsby', 143, 'A writer and wall street trader, Nick Carraway, finds himself drawn to the past and lifestyle of his mysterious millionaire neighbor, Jay Gatsby, amid the riotous parties of the Jazz Age.', NULL),
('Troy', 163, 'An adaptation of Homer''s great epic, the film follows the assault on Troy by the united Greek forces.', NULL);

INSERT INTO Genre (Name)
VALUES 
('Drama'),
('Crime'),
('Action'),
('Comedy'),
('Thriller'),
('Science Fiction'),
('Fantasy'),
('Horror'),
('Romance'),
('Adventure');

INSERT INTO MovieGenre (MovieID, GenreID)
VALUES 
(1, 1),
(1, 2),
(2, 1),
(2, 2),
(3, 3),
(4, 1),
(4, 3),
(5, 3),
(5, 6),
(6, 1),
(6, 3),
(7, 1),
(7, 2),
(7, 3),
(8, 1),
(8, 4),
(9, 1),
(9, 6),
(10, 1),
(10, 2),
(10, 5),
(11, 1),
(11, 4),
(11, 9),
(12, 1),
(12, 9),
(13, 1),
(13, 5),
(14, 1),
(14, 9),
(15, 1),
(15, 10);

INSERT INTO Actor (Name, Surname, Image)
VALUES 
('Morgan', 'Freeman', NULL),
('Marlon', 'Brando', NULL),
('Heath', 'Ledger', NULL),
('Leonardo', 'DiCaprio', NULL),
('Keanu', 'Reeves', NULL),
('Brad', 'Pitt', NULL),
('John', 'Travolta', NULL),
('Tom', 'Hanks', NULL),
('Elijah', 'Wood', NULL),
('Jodie', 'Foster', NULL),
('Christian', 'Bale', NULL),      
('Tom', 'Hardy', NULL),           
('Carrie-Anne', 'Moss', NULL),    
('Helena Bonham', 'Carter', NULL),
('Uma', 'Thurman', NULL),         
('Gary', 'Sinise', NULL),         
('Orlando', 'Bloom', NULL),       
('Anthony', 'Hopkins', NULL);

INSERT INTO MovieActor (MovieID, ActorID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(3, 11),
(4, 12),
(5, 13),
(6, 14),
(7, 15),
(8, 16),
(9, 17),
(10, 18),
(3, 1),
(11, 3),
(12, 4),
(13, 4),
(14, 4),
(15, 6);

INSERT INTO Hall (Name)
VALUES 
('Hall 1'), 
('Hall 2'), 
('Hall 3'),
('Hall 4'),
('Hall 5'),
('Hall 6'),
('Hall 7'),
('Hall 8'),
('Hall 9'),
('Hall 10');

INSERT INTO ViewMode (Name)
VALUES ('2D'), ('3D'), ('4DX'), ('IMAX'), ('Dolby Atmos'), ('ScreenX'), ('VR'), ('HFR');

INSERT INTO Screening (MovieID, HallID, ViewModeID, DateTime, Price, StateMachine)
VALUES 
(1, 1, 1, '2025-01-01 14:00:00', 10.50, 'active'),
(2, 2, 2, '2025-01-02 16:30:00', 13.00, 'draft'),
(3, 3, 3, '2025-01-03 19:00:00', 15.50, 'active'),
(4, 4, 4, '2025-01-04 15:00:00', 18.00, 'active'),
(5, 5, 5, '2025-01-05 18:30:00', 14.50, 'hidden'),
(6, 6, 1, '2025-01-06 17:00:00', 11.00, 'active'),
(7, 7, 2, '2025-01-07 20:00:00', 13.50, 'draft'),
(8, 8, 3, '2025-01-08 14:30:00', 16.00, 'active'),
(9, 9, 4, '2025-01-09 19:30:00', 19.00, 'active'),
(10, 10, 5, '2025-01-10 16:00:00', 15.00, 'hidden'),
(1, 2, 6, '2025-01-11 18:30:00', 14.00, 'active'),
(2, 3, 7, '2025-01-12 15:30:00', 17.50, 'draft'),
(3, 4, 8, '2025-01-13 19:00:00', 16.50, 'active'),
(4, 5, 1, '2025-01-14 14:00:00', 11.50, 'active'),
(5, 6, 2, '2025-01-15 17:30:00', 13.00, 'hidden'),
(11, 1, 1, '2025-01-01 14:00:00', 10.50, 'active'),
(12, 2, 2, '2025-01-02 16:30:00', 13.00, 'active'),
(13, 3, 3, '2025-01-03 19:00:00', 15.50, 'active'),
(14, 4, 4, '2025-01-04 15:00:00', 18.00, 'active'),
(15, 5, 5, '2025-01-05 18:30:00', 14.50, 'active'),
(11, 2, 3, '2025-01-01 19:00:00', 11.50, 'active'),
(12, 3, 4, '2025-01-03 20:30:00', 14.00, 'active'),
(13, 4, 5, '2025-01-04 18:00:00', 17.50, 'active'),
(14, 5, 6, '2025-01-05 17:00:00', 16.00, 'active'),
(15, 6, 7, '2025-01-06 21:30:00', 17.50, 'active');

INSERT INTO Seat (Name)
VALUES 
('A1'), ('A2'), ('A3'), ('A4'), ('A5'), ('A6'), ('A7'), ('A8'),
('B1'), ('B2'), ('B3'), ('B4'), ('B5'), ('B6'), ('B7'), ('B8'),
('C1'), ('C2'), ('C3'), ('C4'), ('C5'), ('C6'), ('C7'), ('C8'),
('D1'), ('D2'), ('D3'), ('D4'), ('D5'), ('D6'), ('D7'), ('D8'),
('E1'), ('E2'), ('E3'), ('E4'), ('E5'), ('E6'), ('E7'), ('E8'),
('F1'), ('F2'), ('F3'), ('F4'), ('F5'), ('F6'), ('F7'), ('F8');

DECLARE @ScreeningID INT = 1;
DECLARE @MaxScreeningID INT;
SELECT @MaxScreeningID = MAX(ID) FROM Screening;
WHILE @ScreeningID <= @MaxScreeningID
BEGIN
    INSERT INTO ScreeningSeat (ScreeningID, SeatID, IsReserved)
    SELECT
        @ScreeningID,
        Seat.ID,
        0
    FROM 
        Seat;
    
    SET @ScreeningID = @ScreeningID + 1;
END

INSERT INTO Payment (UserID, Provider, TransactionID, Amount, DateTime)
VALUES
(1, 'Stripe', 'txn_1', 21.00, '2024-12-02 14:00:00'),
(2, 'Stripe', 'txn_2', 10.50, '2024-12-02 14:00:00'),
(3, 'Cash', NULL, 46.50, '2024-12-03 16:30:00'),
(1, 'Stripe', 'txn_3', 15.50, '2024-12-03 16:30:00'),
(4, 'Cash', NULL, 18.00, '2024-12-04 19:00:00'),
(5, 'Stripe', 'txn_4', 44.00, '2024-12-04 19:00:00'),
(6, 'Stripe', 'txn_5', 16.00, '2024-12-06 15:00:00'),
(7, 'Cash', NULL, 38.00, '2024-12-06 18:30:00'),
(8, 'Stripe', 'txn_6', 28.00, '2024-12-07 17:00:00'),
(8, 'Cash', NULL, 66.00, '2024-12-07 17:00:00');

INSERT INTO Reservation (UserID, ScreeningID, DateTime, NumberOfTickets, TotalPrice, PaymentID, PaymentType, QRCodeBase64)
VALUES 
(1, 1, '2024-12-02 14:00:00', 2, 21.00, 1, 'Stripe', NULL),
(2, 1, '2024-12-02 14:00:00', 1, 10.50, 2, 'Stripe', NULL),
(3, 3, '2024-12-03 16:30:00', 3, 46.50, NULL, 'Cash', NULL),
(1, 3, '2024-12-03 16:30:00', 1, 15.50, 4, 'Stripe', NULL),
(4, 4, '2024-12-04 19:00:00', 1, 18.00, NULL, 'Cash', NULL),
(5, 6, '2024-12-04 19:00:00', 4, 44.00, 6, 'Stripe', NULL),
(6, 8, '2024-12-06 15:00:00', 1, 16.00, 7, 'Stripe', NULL),
(7, 9, '2024-12-06 18:30:00', 2, 38.00, NULL, 'Cash', NULL),
(8, 11, '2024-12-07 17:00:00', 2, 28.00, 9, 'Stripe', NULL),
(8, 13, '2024-12-07 17:00:00', 4, 66.00, NULL, 'Cash', NULL);

INSERT INTO ReservationSeat (ReservationID, SeatID, ReservedAt)
VALUES 
(1, 1, GETDATE()), 
(1, 2, GETDATE()),
(2, 3, GETDATE()),
(3, 4, GETDATE()), 
(3, 5, GETDATE()), 
(3, 6, GETDATE()),
(4, 7, GETDATE()),
(5, 8, GETDATE()),
(6, 9, GETDATE()), 
(6, 10, GETDATE()), 
(6, 11, GETDATE()), 
(6, 12, GETDATE()),
(7, 12, GETDATE()),
(8, 12, GETDATE()),
(8, 13, GETDATE()),
(9, 12, GETDATE()),
(9, 13, GETDATE()),
(10, 12, GETDATE()),
(10, 13, GETDATE()),
(10, 14, GETDATE()),
(10, 15, GETDATE());

MERGE ScreeningSeat AS target
USING (VALUES 
    (1, 1, 1),  
    (1, 2, 1),  
    (1, 3, 1),  
    (3, 4, 1),  
    (3, 5, 1),  
    (3, 6, 1),  
    (3, 7, 1),  
    (4, 8, 1),  
    (6, 9, 1),  
    (6, 10, 1), 
    (6, 11, 1), 
    (6, 12, 1), 
    (8, 12, 1), 
    (9, 12, 1), 
    (9, 13, 1), 
    (11, 12, 1),
    (11, 13, 1),
    (13, 12, 1),
    (13, 13, 1),
    (13, 14, 1),
    (13, 15, 1) 
) AS source (ScreeningID, SeatID, IsReserved)
ON (target.ScreeningID = source.ScreeningID AND target.SeatID = source.SeatID)
WHEN MATCHED THEN 
    UPDATE SET IsReserved = source.IsReserved
WHEN NOT MATCHED THEN 
    INSERT (ScreeningID, SeatID, IsReserved) 
    VALUES (source.ScreeningID, source.SeatID, source.IsReserved);

INSERT INTO Rating (UserID, MovieID, Value, Comment)
VALUES 
(1, 1, 5, 'Great movie!'),
(2, 2, 4, 'Classic film.'),
(3, 3, 5, 'One of the best superhero movies.'),
(4, 4, 4, 'Interesting concept, but could be better.'),
(5, 5, 5, 'Mind-blowing! A must-watch.'),
(6, 6, 3, 'Not my favorite, but still entertaining.'),
(7, 7, 4, 'Very engaging and well-executed.'),
(4, 8, 5, 'Epic conclusion to the trilogy!'),
(5, 9, 4, 'Visually stunning and gripping story.'),
(6, 10, 3, 'Good thriller, but a bit predictable.'),
(1, 11, 5, 'Great movie!'),
(1, 12, 5, 'Great movie!'),
(1, 13, 5, 'Great movie!'),
(1, 14, 5, 'Great movie!'),
(1, 15, 5, 'Great movie!');