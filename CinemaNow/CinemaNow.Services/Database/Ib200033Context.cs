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

    public virtual DbSet<PayPalPayment> PayPalPayments { get; set; }

    public virtual DbSet<Purchase> Purchases { get; set; }

    public virtual DbSet<Rating> Ratings { get; set; }

    public virtual DbSet<Reservation> Reservations { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Screening> Screenings { get; set; }

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
            entity.HasKey(e => e.Id).HasName("PK__Actor__3214EC27CE194242");

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
            entity.HasKey(e => e.Id).HasName("PK__Genre__3214EC2722973E8D");

            entity.ToTable("Genre");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Hall>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Hall__3214EC2765757816");

            entity.ToTable("Hall");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Movie>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Movie__3214EC277D01492A");

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
                        j.HasKey("MovieId", "ActorId").HasName("PK__MovieAct__EEA9AA98D9F0E0E2");
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
                        j.HasKey("MovieId", "GenreId").HasName("PK__MovieGen__BBEAC46F2866D637");
                        j.ToTable("MovieGenre");
                        j.IndexerProperty<int>("MovieId").HasColumnName("MovieID");
                        j.IndexerProperty<int>("GenreId").HasColumnName("GenreID");
                    });
        });

        modelBuilder.Entity<PayPalPayment>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__PayPalPa__3214EC27C10EA167");

            entity.ToTable("PayPalPayment");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Info).IsUnicode(false);
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.PayPalPayments)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__PayPalPay__UserI__4222D4EF");
        });

        modelBuilder.Entity<Purchase>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Purchase__3214EC27E132D1A8");

            entity.ToTable("Purchase");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Date).HasColumnType("date");
            entity.Property(e => e.PayPalPaymentId).HasColumnName("PayPalPaymentID");
            entity.Property(e => e.ScreeningId).HasColumnName("ScreeningID");
            entity.Property(e => e.SeatId).HasColumnName("SeatID");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.PayPalPayment).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.PayPalPaymentId)
                .HasConstraintName("FK__Purchase__PayPal__4F7CD00D");

            entity.HasOne(d => d.Screening).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.ScreeningId)
                .HasConstraintName("FK__Purchase__Screen__4D94879B");

            entity.HasOne(d => d.Seat).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.SeatId)
                .HasConstraintName("FK__Purchase__SeatID__4E88ABD4");

            entity.HasOne(d => d.User).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Purchase__UserID__4CA06362");
        });

        modelBuilder.Entity<Rating>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Rating__3214EC27F2AC819E");

            entity.ToTable("Rating");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Comment).IsUnicode(false);
            entity.Property(e => e.MovieId).HasColumnName("MovieID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Movie).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.MovieId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Rating__MovieID__534D60F1");

            entity.HasOne(d => d.User).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Rating__UserID__52593CB8");
        });

        modelBuilder.Entity<Reservation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Reservat__3214EC2784E288D9");

            entity.ToTable("Reservation");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Date).HasColumnType("date");
            entity.Property(e => e.ScreeningId).HasColumnName("ScreeningID");
            entity.Property(e => e.SeatId).HasColumnName("SeatID");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Screening).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.ScreeningId)
                .HasConstraintName("FK__Reservati__Scree__48CFD27E");

            entity.HasOne(d => d.Seat).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.SeatId)
                .HasConstraintName("FK__Reservati__SeatI__49C3F6B7");

            entity.HasOne(d => d.User).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Reservati__UserI__47DBAE45");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Role__3214EC271F7275ED");

            entity.ToTable("Role");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Screening>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Screenin__3214EC27634AFAC4");

            entity.ToTable("Screening");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Date).HasColumnType("date");
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

        modelBuilder.Entity<Seat>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Seat__3214EC27AB2D2072");

            entity.ToTable("Seat");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.ScreeningId).HasColumnName("ScreeningID");

            entity.HasOne(d => d.Screening).WithMany(p => p.Seats)
                .HasForeignKey(d => d.ScreeningId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__Seat__ScreeningI__44FF419A");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__User__3214EC27BEF70DCB");

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
                        j.HasKey("UserId", "RoleId").HasName("PK__UserRole__AF27604F5B67A08A");
                        j.ToTable("UserRole");
                        j.IndexerProperty<int>("UserId").HasColumnName("UserID");
                        j.IndexerProperty<int>("RoleId").HasColumnName("RoleID");
                    });
        });

        modelBuilder.Entity<ViewMode>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ViewMode__3214EC27ABC231D6");

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
