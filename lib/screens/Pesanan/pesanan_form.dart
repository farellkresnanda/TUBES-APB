import 'package:flutter/material.dart';
import 'package:tubes_1/screens/Pesanan/pesanan_invoice.dart';

class FormPesan extends StatefulWidget {
  final String displayLokasi;
  final String kategori;

  const FormPesan({
    super.key,
    required this.kategori,
    this.displayLokasi = 'Lokasi belum ditentukan',
  });

  @override
  State<FormPesan> createState() => _FormPesanScreenState();
}

class _FormPesanScreenState extends State<FormPesan> {
  int jumlahTukang = 1;
  int selectedJamKerja = 12;
  final TextEditingController catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Color(0xFFF4A300)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Cari tukang?, TukangKu Solusinya! ${widget.kategori}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "TukangKu",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Mitra Terpercaya Penyedia Tenaga Konstruksi.",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Form Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kami siap membantu, mohon isi data dibawah ya.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lokasi
                    buildRoundedBox(
                      icon: Icons.location_on,
                      label: "Lokasi: ${widget.displayLokasi}",
                    ),

                    const SizedBox(height: 20),

                    // Jumlah tukang
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.engineering),
                          const SizedBox(width: 8),
                          const Text("Tentukan jumlah tukang"),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (jumlahTukang > 1) {
                                setState(() {
                                  jumlahTukang--;
                                });
                              }
                            },
                          ),
                          Text('$jumlahTukang'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                jumlahTukang++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Jam kerja tukang
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          const Text("Tentukan jam kerja tukang"),
                          const Spacer(),
                          DropdownButton<int>(
                            value: selectedJamKerja,
                            underline: const SizedBox(),
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedJamKerja = newValue!;
                              });
                            },
                            items:
                                <int>[
                                  3,
                                  6,
                                  8,
                                  10,
                                  12,
                                ].map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('$value jam'),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Catatan
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.edit_note),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: catatanController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Catatan untuk pekerja',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => pesananInvoice(
                            kategori: widget.kategori,
                            alamat: widget.displayLokasi,
                            jumlah_tukang: jumlahTukang,
                            jam_kerja: selectedJamKerja,
                            deskripsi: catatanController.text,
                          ),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  "Selanjutnya",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildRoundedBox({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
