using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace CinemaNow.Services.Database;

public partial class Ib200033Context : DbContext
{
    public Ib200033Context()
    {
    }

    public Ib200033Context(DbContextOptions<Ib200033Context> options)
        : base(options)
    {
    }

    public virtual DbSet<Actor> Actors { get; set; }

    public virtual DbSet<Genre> Genres { get; set; }

    public virtual DbSet<Hall> Halls { get; set; }

    public virtual DbSet<Movie> Movies { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Rating> Ratings { get; set; }

    public virtual DbSet<Reservation> Reservations { get; set; }

    public virtual DbSet<ReservationSeat> ReservationSeats { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Screening> Screenings { get; set; }

    public virtual DbSet<ScreeningSeat> ScreeningSeats { get; set; }

    public virtual DbSet<Seat> Seats { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<ViewMode> ViewModes { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost, 1434;Initial Catalog=IB200033; user=sa; Password=QWEasd123!; TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Actor>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Actor__3214EC27C9CE111D");

            entity.ToTable("Actor");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Surname)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Genre>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Genre__3214EC271D5CB6F1");

            entity.ToTable("Genre");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Hall>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Hall__3214EC27F89CB41C");

            entity.ToTable("Hall");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Movie>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Movie__3214EC2760E76F40");

            entity.ToTable("Movie");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Synopsis).IsUnicode(false);
            entity.Property(e => e.Title)
                .HasMaxLength(100)
                .IsUnicode(false);

            entity.HasMany(d => d.Actors).WithMany(p => p.Movies)
                .UsingEntity<Dictionary<string, object>>(
                    "MovieActor",
                    r => r.HasOne<Actor>().WithMany()
                        .HasForeignKey("ActorId")
                        .HasConstraintName("FK__MovieActo__Actor__36B12243"),
                    l => l.HasOne<Movie>().WithMany()
                        .HasForeignKey("MovieId")
                        .HasConstraintName("FK__MovieActo__Movie__35BCFE0A"),
                    j =>
                    {
                        j.HasKey("MovieId", "ActorId").HasName("PK__MovieAct__EEA9AA98E1B323ED");
                        j.ToTable("MovieActor");
                        j.IndexerProperty<int>("MovieId").HasColumnName("MovieID");
                        j.IndexerProperty<int>("ActorId").HasColumnName("ActorID");
                    });

            entity.HasMany(d => d.Genres).WithMany(p => p.Movies)
                .UsingEntity<Dictionary<string, object>>(
                    "MovieGenre",
                    r => r.HasOne<Genre>().WithMany()
                        .HasForeignKey("GenreId")
                        .HasConstraintName("FK__MovieGenr__Genre__30F848ED"),
                    l => l.HasOne<Movie>().WithMany()
                        .HasForeignKey("MovieId")
                        .HasConstraintName("FK__MovieGenr__Movie__300424B4"),
                    j =>
                    {
                        j.HasKey("MovieId", "GenreId").HasName("PK__MovieGen__BBEAC46FB802F722");
                        j.ToTable("MovieGenre");
                        j.IndexerProperty<int>("MovieId").HasColumnName("MovieID");
                        j.IndexerProperty<int>("GenreId").HasColumnName("GenreID");
                    });
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Payment__3214EC271CB56BA8");

            entity.ToTable("Payment");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DateTime).HasColumnType("datetime");
            entity.Property(e => e.Provider)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.TransactionId)
                .HasMaxLength(255)
                .IsUnicode(false)
                .HasColumnName("TransactionID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.Payments)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Payment__UserID__48CFD27E");
        });

        modelBuilder.Entity<Rating>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Rating__3214EC27387BA899");

            entity.ToTable("Rating");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Comment).IsUnicode(false);
            entity.Property(e => e.MovieId).HasColumnName("MovieID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Movie).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.MovieId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Rating__MovieID__5535A963");

            entity.HasOne(d => d.User).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Rating__UserID__5441852A");
        });

        modelBuilder.Entity<Reservation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Reservat__3214EC2799EA1ACA");

            entity.ToTable("Reservation");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DateTime).HasColumnType("datetime");
            entity.Property(e => e.PaymentId).HasColumnName("PaymentID");
            entity.Property(e => e.ScreeningId).HasColumnName("ScreeningID");
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Payment).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.PaymentId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__Reservati__Payme__4D94879B");

            entity.HasOne(d => d.Screening).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.ScreeningId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Reservati__Scree__4CA06362");

            entity.HasOne(d => d.User).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Reservati__UserI__4BAC3F29");
        });

        modelBuilder.Entity<ReservationSeat>(entity =>
        {
            entity.HasKey(e => new { e.ReservationId, e.SeatId }).HasName("PK__Reservat__94FF2E393F3BF08F");

            entity.ToTable("ReservationSeat");

            entity.Property(e => e.ReservationId).HasColumnName("ReservationID");
            entity.Property(e => e.SeatId).HasColumnName("SeatID");
            entity.Property(e => e.ReservedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Reservation).WithMany(p => p.ReservationSeats)
                .HasForeignKey(d => d.ReservationId)
                .HasConstraintName("FK__Reservati__Reser__5070F446");

            entity.HasOne(d => d.Seat).WithMany(p => p.ReservationSeats)
                .HasForeignKey(d => d.SeatId)
                .HasConstraintName("FK__Reservati__SeatI__5165187F");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Role__3214EC27B5300407");

            entity.ToTable("Role");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Screening>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Screenin__3214EC2793602116");

            entity.ToTable("Screening");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DateTime).HasColumnType("datetime");
            entity.Property(e => e.HallId).HasColumnName("HallID");
            entity.Property(e => e.MovieId).HasColumnName("MovieID");
            entity.Property(e => e.Price).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.StateMachine)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.ViewModeId).HasColumnName("ViewModeID");

            entity.HasOne(d => d.Hall).WithMany(p => p.Screenings)
                .HasForeignKey(d => d.HallId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Screening__HallI__3E52440B");

            entity.HasOne(d => d.Movie).WithMany(p => p.Screenings)
                .HasForeignKey(d => d.MovieId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Screening__Movie__3D5E1FD2");

            entity.HasOne(d => d.ViewMode).WithMany(p => p.Screenings)
                .HasForeignKey(d => d.ViewModeId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Screening__ViewM__3F466844");
        });

        modelBuilder.Entity<ScreeningSeat>(entity =>
        {
            entity.HasKey(e => new { e.ScreeningId, e.SeatId }).HasName("PK__Screenin__5425955136362401");

            entity.ToTable("ScreeningSeat");

            entity.Property(e => e.ScreeningId).HasColumnName("ScreeningID");
            entity.Property(e => e.SeatId).HasColumnName("SeatID");
            entity.Property(e => e.IsReserved).HasDefaultValueSql("((0))");

            entity.HasOne(d => d.Screening).WithMany(p => p.ScreeningSeats)
                .HasForeignKey(d => d.ScreeningId)
                .HasConstraintName("FK__Screening__Scree__44FF419A");

            entity.HasOne(d => d.Seat).WithMany(p => p.ScreeningSeats)
                .HasForeignKey(d => d.SeatId)
                .HasConstraintName("FK__Screening__SeatI__45F365D3");
        });

        modelBuilder.Entity<Seat>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Seat__3214EC27B526E7D3");

            entity.ToTable("Seat");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(10)
                .IsUnicode(false);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__User__3214EC278F0F98C9");

            entity.ToTable("User");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.PasswordHash).HasMaxLength(128);
            entity.Property(e => e.PasswordSalt).HasMaxLength(128);
            entity.Property(e => e.Surname)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Username)
                .HasMaxLength(50)
                .IsUnicode(false);

            entity.HasMany(d => d.Roles).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "UserRole",
                    r => r.HasOne<Role>().WithMany()
                        .HasForeignKey("RoleId")
                        .HasConstraintName("FK__UserRole__RoleID__29572725"),
                    l => l.HasOne<User>().WithMany()
                        .HasForeignKey("UserId")
                        .HasConstraintName("FK__UserRole__UserID__286302EC"),
                    j =>
                    {
                        j.HasKey("UserId", "RoleId").HasName("PK__UserRole__AF27604F4BBB5184");
                        j.ToTable("UserRole");
                        j.IndexerProperty<int>("UserId").HasColumnName("UserID");
                        j.IndexerProperty<int>("RoleId").HasColumnName("RoleID");
                    });
        });

        modelBuilder.Entity<ViewMode>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ViewMode__3214EC27E282354D");

            entity.ToTable("ViewMode");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
