import 'package:hive/hive.dart';
import 'produk_model.dart';

/// TypeAdapter memberi tahu Hive cara menyimpan (write)
/// dan membaca (read) objek Produk dalam format biner.
///
/// ATURAN PENTING MODUL:
/// 1. typeId harus unik per model class (Paket 9 memakai typeId = 9).
/// 2. Urutan read HARUS sama persis dengan urutan write.
class ProdukAdapter extends TypeAdapter<Produk> {
  @override
  final int typeId = 9;

  @override
  Produk read(BinaryReader reader) {
    final sku = reader.readString();
    final nama = reader.readString();
    final kategori = reader.readString();
    final hargaBeli = reader.readDouble();
    final hargaJual = reader.readDouble();
    final stok = reader.readInt();

    return Produk(
      sku: sku,
      nama: nama,
      kategori: kategori,
      hargaBeli: hargaBeli,
      hargaJual: hargaJual,
      stok: stok,
    );
  }

  @override
  void write(BinaryWriter writer, Produk obj) {
    writer.writeString(obj.sku);
    writer.writeString(obj.nama);
    writer.writeString(obj.kategori);
    writer.writeDouble(obj.hargaBeli);
    writer.writeDouble(obj.hargaJual);
    writer.writeInt(obj.stok);
  }
}
