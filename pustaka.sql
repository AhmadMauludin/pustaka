CREATE TABLE `anggota` (
  `id_anggota` int(11) PRIMARY KEY NOT NULL,
  `user_id` int(11),
  `nis` varchar(20),
  `alamat` text,
  `no_hp` varchar(15),
  `tanggal_daftar` date
);

CREATE TABLE `buku` (
  `id_buku` int(11) PRIMARY KEY NOT NULL,
  `isbn` varchar(50),
  `judul` varchar(255),
  `id_kategori` int(11),
  `id_penulis` int(11),
  `id_penerbit` int(11),
  `tahun_terbit` year(4),
  `jumlah` int(11) DEFAULT 0,
  `tersedia` int(11) DEFAULT 0,
  `deskripsi` text,
  `cover` varchar(255)
);

CREATE TABLE `buku_rak` (
  `id` int(11) PRIMARY KEY NOT NULL,
  `id_buku` int(11),
  `id_rak` int(11)
);

CREATE TABLE `denda` (
  `id_denda` int(11) PRIMARY KEY NOT NULL,
  `id_pengembalian` int(11),
  `jumlah_denda` decimal(10,2),
  `status` ENUM ('belum_bayar', 'sudah_bayar') DEFAULT 'belum_bayar'
);

CREATE TABLE `detail_peminjaman` (
  `id_detail` int(11) PRIMARY KEY NOT NULL,
  `id_peminjaman` int(11),
  `id_buku` int(11),
  `jumlah` int(11)
);

CREATE TABLE `kategori` (
  `id_kategori` int(11) PRIMARY KEY NOT NULL,
  `nama_kategori` varchar(100)
);

CREATE TABLE `log_aktivitas` (
  `id_log` int(11) PRIMARY KEY NOT NULL,
  `user_id` int(11),
  `aktivitas` text,
  `waktu` timestamp NOT NULL DEFAULT (current_timestamp())
);

CREATE TABLE `peminjaman` (
  `id_peminjaman` int(11) PRIMARY KEY NOT NULL,
  `id_anggota` int(11),
  `id_petugas` int(11),
  `tanggal_pinjam` date,
  `tanggal_kembali` date,
  `status` ENUM ('dipinjam', 'kembali', 'terlambat') DEFAULT 'dipinjam'
);

CREATE TABLE `penarikan` (
  `id_penarikan` int(11) PRIMARY KEY NOT NULL,
  `id_peminjaman` int(11),
  `alamat` text,
  `biaya` decimal(10,2),
  `status` ENUM ('menunggu', 'diproses', 'diambil', 'selesai') DEFAULT 'menunggu',
  `tanggal_ambil` date,
  `petugas_id` int(11)
);

CREATE TABLE `penerbit` (
  `id_penerbit` int(11) PRIMARY KEY NOT NULL,
  `nama_penerbit` varchar(100),
  `alamat` text
);

CREATE TABLE `pengaturan` (
  `id` int(11) PRIMARY KEY NOT NULL,
  `nama_aplikasi` varchar(100),
  `denda_per_hari` decimal(10,2),
  `maksimal_pinjam` int(11),
  `lama_pinjam` int(11)
);

CREATE TABLE `pengembalian` (
  `id_pengembalian` int(11) PRIMARY KEY NOT NULL,
  `id_peminjaman` int(11),
  `tanggal_dikembalikan` date,
  `denda` decimal(10,2) DEFAULT 0
);

CREATE TABLE `pengiriman` (
  `id_pengiriman` int(11) PRIMARY KEY NOT NULL,
  `id_peminjaman` int(11),
  `alamat` text,
  `biaya` decimal(10,2),
  `status` ENUM ('menunggu', 'diproses', 'dikirim', 'sampai') DEFAULT 'menunggu',
  `tanggal_kirim` date,
  `petugas_id` int(11)
);

CREATE TABLE `penulis` (
  `id_penulis` int(11) PRIMARY KEY NOT NULL,
  `nama_penulis` varchar(100)
);

CREATE TABLE `petugas` (
  `id_petugas` int(11) PRIMARY KEY NOT NULL,
  `user_id` int(11),
  `jabatan` varchar(50)
);

CREATE TABLE `rak` (
  `id_rak` int(11) PRIMARY KEY NOT NULL,
  `nama_rak` varchar(50),
  `lokasi` varchar(100)
);

CREATE TABLE `reservasi` (
  `id_reservasi` int(11) PRIMARY KEY NOT NULL,
  `id_anggota` int(11),
  `id_buku` int(11),
  `tanggal_reservasi` date,
  `status` ENUM ('menunggu', 'disetujui', 'dibatalkan') DEFAULT 'menunggu'
);

CREATE TABLE `transaksi` (
  `id_transaksi` int(11) PRIMARY KEY NOT NULL,
  `id_peminjaman` int(11),
  `jenis` ENUM ('denda', 'pengiriman', 'penarikan'),
  `jumlah` decimal(10,2),
  `status` ENUM ('belum_bayar', 'lunas') DEFAULT 'belum_bayar',
  `tanggal` timestamp NOT NULL DEFAULT (current_timestamp())
);

CREATE TABLE `ulasan` (
  `id_ulasan` int(11) PRIMARY KEY NOT NULL,
  `id_buku` int(11),
  `id_anggota` int(11),
  `rating` int(11),
  `komentar` text,
  `tanggal` timestamp NOT NULL DEFAULT (current_timestamp())
);

CREATE TABLE `users` (
  `id` int(11) PRIMARY KEY NOT NULL,
  `nama` varchar(100),
  `email` varchar(100),
  `username` varchar(50),
  `password` varchar(255),
  `role` ENUM ('admin', 'petugas', 'anggota') DEFAULT 'anggota',
  `foto` varchar(255),
  `status` ENUM ('aktif', 'nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT (current_timestamp())
);

ALTER TABLE `anggota` ADD CONSTRAINT `anggota_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `buku` ADD CONSTRAINT `buku_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`);

ALTER TABLE `buku` ADD CONSTRAINT `buku_ibfk_2` FOREIGN KEY (`id_penulis`) REFERENCES `penulis` (`id_penulis`);

ALTER TABLE `buku` ADD CONSTRAINT `buku_ibfk_3` FOREIGN KEY (`id_penerbit`) REFERENCES `penerbit` (`id_penerbit`);

ALTER TABLE `buku_rak` ADD CONSTRAINT `buku_rak_ibfk_1` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`) ON DELETE CASCADE;

ALTER TABLE `buku_rak` ADD CONSTRAINT `buku_rak_ibfk_2` FOREIGN KEY (`id_rak`) REFERENCES `rak` (`id_rak`) ON DELETE CASCADE;

ALTER TABLE `denda` ADD CONSTRAINT `denda_ibfk_1` FOREIGN KEY (`id_pengembalian`) REFERENCES `pengembalian` (`id_pengembalian`);

ALTER TABLE `detail_peminjaman` ADD CONSTRAINT `detail_peminjaman_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`) ON DELETE CASCADE;

ALTER TABLE `transaksi` ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`) ON DELETE CASCADE;

ALTER TABLE `detail_peminjaman` ADD CONSTRAINT `detail_peminjaman_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`);

ALTER TABLE `log_aktivitas` ADD CONSTRAINT `log_aktivitas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `peminjaman` ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_anggota`) REFERENCES `anggota` (`id_anggota`);

ALTER TABLE `peminjaman` ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_petugas`) REFERENCES `petugas` (`id_petugas`);

ALTER TABLE `penarikan` ADD CONSTRAINT `penarikan_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`);

ALTER TABLE `penarikan` ADD CONSTRAINT `penarikan_ibfk_2` FOREIGN KEY (`petugas_id`) REFERENCES `petugas` (`id_petugas`);

ALTER TABLE `pengembalian` ADD CONSTRAINT `pengembalian_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`);

ALTER TABLE `pengiriman` ADD CONSTRAINT `pengiriman_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`);

ALTER TABLE `pengiriman` ADD CONSTRAINT `pengiriman_ibfk_2` FOREIGN KEY (`petugas_id`) REFERENCES `petugas` (`id_petugas`);

ALTER TABLE `petugas` ADD CONSTRAINT `petugas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `reservasi` ADD CONSTRAINT `reservasi_ibfk_1` FOREIGN KEY (`id_anggota`) REFERENCES `anggota` (`id_anggota`);

ALTER TABLE `reservasi` ADD CONSTRAINT `reservasi_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`);

ALTER TABLE `ulasan` ADD CONSTRAINT `ulasan_ibfk_1` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`);

ALTER TABLE `ulasan` ADD CONSTRAINT `ulasan_ibfk_2` FOREIGN KEY (`id_anggota`) REFERENCES `anggota` (`id_anggota`);

-- Disable foreign key checks for INSERT
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `pengaturan` (`id`, `nama_aplikasi`, `denda_per_hari`, `maksimal_pinjam`, `lama_pinjam`)
VALUES
  (1, 'Sistem Perpustakaan', 1000, 3, 7);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;