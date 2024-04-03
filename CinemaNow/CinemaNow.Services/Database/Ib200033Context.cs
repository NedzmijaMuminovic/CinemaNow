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

    public virtual DbSet<Movie> Movies { get; set; }

    public virtual DbSet<PayPalPayment> PayPalPayments { get; set; }

    public virtual DbSet<Purchase> Purchases { get; set; }

    public virtual DbSet<Rating> Ratings { get; set; }

    public virtual DbSet<Reservation> Reservations { get; set; }

    public virtual DbSet<Screening> Screenings { get; set; }

    public virtual DbSet<Seat> Seats { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost, 1434;Initial Catalog=IB200033; user=sa; Password=QWEasd123!; TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Actor>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Actor__3214EC2791D3ECA8");

            entity.ToTable("Actor");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Image).IsUnicode(false);
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Surname)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Movie>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Movie__3214EC270A9146D5");

            entity.ToTable("Movie");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Genre)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Synopsis).IsUnicode(false);
            entity.Property(e => e.Title)
                .HasMaxLength(100)
                .IsUnicode(false);

            entity.HasMany(d => d.Actors).WithMany(p => p.Movies)
                .UsingEntity<Dictionary<string, object>>(
                    "MovieActor",
                    r => r.HasOne<Actor>().WithMany()
                        .HasForeignKey("ActorId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__MovieActo__Actor__2B3F6F97"),
                    l => l.HasOne<Movie>().WithMany()
                        .HasForeignKey("MovieId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__MovieActo__Movie__2A4B4B5E"),
                    j =>
                    {
                        j.HasKey("MovieId", "ActorId").HasName("PK__MovieAct__EEA9AA983624E15F");
                        j.ToTable("MovieActor");
                        j.IndexerProperty<int>("MovieId").HasColumnName("MovieID");
                        j.IndexerProperty<int>("ActorId").HasColumnName("ActorID");
                    });
        });

        modelBuilder.Entity<PayPalPayment>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__PayPalPa__3214EC278B9B9DA8");

            entity.ToTable("PayPalPayment");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Info).IsUnicode(false);
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.PayPalPayments)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__PayPalPay__UserI__30F848ED");
        });

        modelBuilder.Entity<Purchase>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Purchase__3214EC2700B7D43F");

            entity.ToTable("Purchase");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
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
                .HasConstraintName("FK__Purchase__PayPal__3D5E1FD2");

            entity.HasOne(d => d.Screening).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.ScreeningId)
                .HasConstraintName("FK__Purchase__Screen__3C69FB99");

            entity.HasOne(d => d.Seat).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.SeatId)
                .HasConstraintName("FK__Purchase__SeatID__3E52440B");

            entity.HasOne(d => d.User).WithMany(p => p.Purchases)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Purchase__UserID__3B75D760");
        });

        modelBuilder.Entity<Rating>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Rating__3214EC276CED707F");

            entity.ToTable("Rating");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Comment).IsUnicode(false);
            entity.Property(e => e.MovieId).HasColumnName("MovieID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Movie).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.MovieId)
                .HasConstraintName("FK__Rating__MovieID__4222D4EF");

            entity.HasOne(d => d.User).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Rating__UserID__412EB0B6");
        });

        modelBuilder.Entity<Reservation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Reservat__3214EC2725DBCB7D");

            entity.ToTable("Reservation");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
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
                .HasConstraintName("FK__Reservati__Scree__37A5467C");

            entity.HasOne(d => d.Seat).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.SeatId)
                .HasConstraintName("FK__Reservati__SeatI__38996AB5");

            entity.HasOne(d => d.User).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Reservati__UserI__36B12243");
        });

        modelBuilder.Entity<Screening>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Screenin__3214EC27EEB30F8E");

            entity.ToTable("Screening");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Date).HasColumnType("date");
            entity.Property(e => e.Hall)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.MovieId).HasColumnName("MovieID");
            entity.Property(e => e.Price).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.Movie).WithMany(p => p.Screenings)
                .HasForeignKey(d => d.MovieId)
                .HasConstraintName("FK__Screening__Movie__2E1BDC42");
        });

        modelBuilder.Entity<Seat>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Seat__3214EC27B7E20BF2");

            entity.ToTable("Seat");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Name)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.ScreeningId).HasColumnName("ScreeningID");

            entity.HasOne(d => d.Screening).WithMany(p => p.Seats)
                .HasForeignKey(d => d.ScreeningId)
                .HasConstraintName("FK__Seat__ScreeningI__33D4B598");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__User__3214EC2762B1B992");

            entity.ToTable("User");

            entity.Property(e => e.Id)
                .ValueGeneratedNever()
                .HasColumnName("ID");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Image).IsUnicode(false);
            entity.Property(e => e.Name)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Password)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Surname)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Username)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
