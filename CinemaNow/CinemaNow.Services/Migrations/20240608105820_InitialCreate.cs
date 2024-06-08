using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CinemaNow.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Actor",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Surname = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    ImageThumb = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Actor__3214EC27F4EBCAE2", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Genre",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Genre__3214EC2786854726", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Movie",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Duration = table.Column<int>(type: "int", nullable: true),
                    Synopsis = table.Column<string>(type: "varchar(max)", unicode: false, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    ImageThumb = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Movie__3214EC277413BFFF", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Role",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Role__3214EC27FD681978", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "User",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Surname = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Username = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    PasswordSalt = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    ImageThumb = table.Column<byte[]>(type: "varbinary(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__User__3214EC277C797F01", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "MovieActor",
                columns: table => new
                {
                    MovieID = table.Column<int>(type: "int", nullable: false),
                    ActorID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__MovieAct__EEA9AA98EF0F8CF7", x => new { x.MovieID, x.ActorID });
                    table.ForeignKey(
                        name: "FK__MovieActo__Actor__36B12243",
                        column: x => x.ActorID,
                        principalTable: "Actor",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__MovieActo__Movie__35BCFE0A",
                        column: x => x.MovieID,
                        principalTable: "Movie",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "MovieGenre",
                columns: table => new
                {
                    MovieID = table.Column<int>(type: "int", nullable: false),
                    GenreID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__MovieGen__BBEAC46F651A80DC", x => new { x.MovieID, x.GenreID });
                    table.ForeignKey(
                        name: "FK__MovieGenr__Genre__30F848ED",
                        column: x => x.GenreID,
                        principalTable: "Genre",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__MovieGenr__Movie__300424B4",
                        column: x => x.MovieID,
                        principalTable: "Movie",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Screening",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MovieID = table.Column<int>(type: "int", nullable: true),
                    Date = table.Column<DateTime>(type: "date", nullable: true),
                    Time = table.Column<TimeSpan>(type: "time", nullable: true),
                    Hall = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    Price = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    StateMachine = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Screenin__3214EC27A540ED58", x => x.ID);
                    table.ForeignKey(
                        name: "FK__Screening__Movie__398D8EEE",
                        column: x => x.MovieID,
                        principalTable: "Movie",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "PayPalPayment",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    Info = table.Column<string>(type: "varchar(max)", unicode: false, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PayPalPa__3214EC276A200272", x => x.ID);
                    table.ForeignKey(
                        name: "FK__PayPalPay__UserI__3C69FB99",
                        column: x => x.UserID,
                        principalTable: "User",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Rating",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    MovieID = table.Column<int>(type: "int", nullable: true),
                    Value = table.Column<int>(type: "int", nullable: true),
                    Comment = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Rating__3214EC2764658F9A", x => x.ID);
                    table.ForeignKey(
                        name: "FK__Rating__MovieID__4D94879B",
                        column: x => x.MovieID,
                        principalTable: "Movie",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__Rating__UserID__4CA06362",
                        column: x => x.UserID,
                        principalTable: "User",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "UserRole",
                columns: table => new
                {
                    UserID = table.Column<int>(type: "int", nullable: false),
                    RoleID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__UserRole__AF27604F5801D74A", x => new { x.UserID, x.RoleID });
                    table.ForeignKey(
                        name: "FK__UserRole__RoleID__29572725",
                        column: x => x.RoleID,
                        principalTable: "Role",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__UserRole__UserID__286302EC",
                        column: x => x.UserID,
                        principalTable: "User",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Seat",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: false),
                    ScreeningID = table.Column<int>(type: "int", nullable: true),
                    IsReserved = table.Column<bool>(type: "bit", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Seat__3214EC276828327D", x => x.ID);
                    table.ForeignKey(
                        name: "FK__Seat__ScreeningI__3F466844",
                        column: x => x.ScreeningID,
                        principalTable: "Screening",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Purchase",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    ScreeningID = table.Column<int>(type: "int", nullable: true),
                    SeatID = table.Column<int>(type: "int", nullable: true),
                    Date = table.Column<DateTime>(type: "date", nullable: true),
                    NumberOfTickets = table.Column<int>(type: "int", nullable: true),
                    TotalPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    Status = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    PayPalPaymentID = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Purchase__3214EC27E3E4EDB5", x => x.ID);
                    table.ForeignKey(
                        name: "FK__Purchase__PayPal__48CFD27E",
                        column: x => x.PayPalPaymentID,
                        principalTable: "PayPalPayment",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__Purchase__Screen__47DBAE45",
                        column: x => x.ScreeningID,
                        principalTable: "Screening",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__Purchase__SeatID__49C3F6B7",
                        column: x => x.SeatID,
                        principalTable: "Seat",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__Purchase__UserID__46E78A0C",
                        column: x => x.UserID,
                        principalTable: "User",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Reservation",
                columns: table => new
                {
                    ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: true),
                    ScreeningID = table.Column<int>(type: "int", nullable: true),
                    SeatID = table.Column<int>(type: "int", nullable: true),
                    Date = table.Column<DateTime>(type: "date", nullable: true),
                    NumberOfTickets = table.Column<int>(type: "int", nullable: true),
                    TotalPrice = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    Status = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Reservat__3214EC271299548E", x => x.ID);
                    table.ForeignKey(
                        name: "FK__Reservati__Scree__4316F928",
                        column: x => x.ScreeningID,
                        principalTable: "Screening",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__Reservati__SeatI__440B1D61",
                        column: x => x.SeatID,
                        principalTable: "Seat",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK__Reservati__UserI__4222D4EF",
                        column: x => x.UserID,
                        principalTable: "User",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_MovieActor_ActorID",
                table: "MovieActor",
                column: "ActorID");

            migrationBuilder.CreateIndex(
                name: "IX_MovieGenre_GenreID",
                table: "MovieGenre",
                column: "GenreID");

            migrationBuilder.CreateIndex(
                name: "IX_PayPalPayment_UserID",
                table: "PayPalPayment",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Purchase_PayPalPaymentID",
                table: "Purchase",
                column: "PayPalPaymentID");

            migrationBuilder.CreateIndex(
                name: "IX_Purchase_ScreeningID",
                table: "Purchase",
                column: "ScreeningID");

            migrationBuilder.CreateIndex(
                name: "IX_Purchase_SeatID",
                table: "Purchase",
                column: "SeatID");

            migrationBuilder.CreateIndex(
                name: "IX_Purchase_UserID",
                table: "Purchase",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Rating_MovieID",
                table: "Rating",
                column: "MovieID");

            migrationBuilder.CreateIndex(
                name: "IX_Rating_UserID",
                table: "Rating",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Reservation_ScreeningID",
                table: "Reservation",
                column: "ScreeningID");

            migrationBuilder.CreateIndex(
                name: "IX_Reservation_SeatID",
                table: "Reservation",
                column: "SeatID");

            migrationBuilder.CreateIndex(
                name: "IX_Reservation_UserID",
                table: "Reservation",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Screening_MovieID",
                table: "Screening",
                column: "MovieID");

            migrationBuilder.CreateIndex(
                name: "IX_Seat_ScreeningID",
                table: "Seat",
                column: "ScreeningID");

            migrationBuilder.CreateIndex(
                name: "IX_UserRole_RoleID",
                table: "UserRole",
                column: "RoleID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MovieActor");

            migrationBuilder.DropTable(
                name: "MovieGenre");

            migrationBuilder.DropTable(
                name: "Purchase");

            migrationBuilder.DropTable(
                name: "Rating");

            migrationBuilder.DropTable(
                name: "Reservation");

            migrationBuilder.DropTable(
                name: "UserRole");

            migrationBuilder.DropTable(
                name: "Actor");

            migrationBuilder.DropTable(
                name: "Genre");

            migrationBuilder.DropTable(
                name: "PayPalPayment");

            migrationBuilder.DropTable(
                name: "Seat");

            migrationBuilder.DropTable(
                name: "Role");

            migrationBuilder.DropTable(
                name: "User");

            migrationBuilder.DropTable(
                name: "Screening");

            migrationBuilder.DropTable(
                name: "Movie");
        }
    }
}
