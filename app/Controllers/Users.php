<?php

namespace App\Controllers;

use App\Models\UsersModel;

class Users extends BaseController
{
    protected $users;

    public function __construct()
    {
        $this->users = new UsersModel();
    }

    public function create()
    {
        return view('users/create');
    }

    public function store()
    {
        // Validasi form
        $validation = \Config\Services::validation();
        $validation->setRules([
            'nama'     => 'required',
            'email'    => 'required|valid_email',
            'username' => 'required|is_unique[users.username]',
            'password' => 'required|min_length[4]',
            'role'     => 'required',
        ]);

        if (!$validation->withRequest($this->request)->run()) {
            return redirect()->back()->with('error', implode('<br>', $validation->getErrors()));
        }

        // ============== Upload Foto ==============
        $foto = $this->request->getFile('foto');
        $namaFoto = null;

        if ($foto && $foto->isValid() && !$foto->hasMoved()) {
            $namaFoto = $foto->getRandomName();
            $foto->move(FCPATH . 'uploads/users', $namaFoto);
        }

        // ============== Simpan Data ==============
        $this->users->save([
            'nama'     => $this->request->getPost('nama'),
            'email'    => $this->request->getPost('email'),
            'username' => $this->request->getPost('username'),
            'password' => password_hash($this->request->getPost('password'), PASSWORD_DEFAULT),
            'role'     => $this->request->getPost('role'),
            'foto'     => $namaFoto
        ]);

        return redirect()->to('/login')->with('success', 'User berhasil ditambahkan!');
    }

    public function index()
    {
        $keyword = $this->request->getGet('keyword');
        $role = $this->request->getGet('role');

        $builder = $this->users;

        if ($keyword) {
            $builder = $builder->like('nama', $keyword);
        }

        if ($role) {
            $builder = $builder->where('role', $role);
        }

        $data['users'] = $builder->paginate(10);
        $data['pager'] = $this->users->pager;

        return view('users/index', $data);
    }

    public function edit($id)
    {
        $data['user'] = $this->users->find($id);
        return view('users/edit', $data);
    }

    public function update($id)
    {
        $user = $this->users->find($id);  // Ambil data user lama

        $fotoBaru = $this->request->getFile('foto');

        // Default: gunakan foto lama
        $namaFoto = $user['foto'];

        // Jika user upload foto baru
        if ($fotoBaru && $fotoBaru->isValid() && $fotoBaru->getName() != '') {

            // Hapus foto lama jika ada
            if (!empty($user['foto']) && file_exists(FCPATH . 'uploads/users/' . $user['foto'])) {
                unlink(FCPATH . 'uploads/users/' . $user['foto']);
            }

            // Simpan foto baru
            $namaFoto = $fotoBaru->getRandomName();
            $fotoBaru->move(FCPATH . 'uploads/users', $namaFoto);
        }

        // Data yang akan diupdate
        $data = [
            'nama'     => $this->request->getPost('nama'),
            'email'    => $this->request->getPost('email'),
            'username' => $this->request->getPost('username'),
            'role'     => $this->request->getPost('role'),
            'foto'     => $namaFoto
        ];

        // Jika password diisi, baru update
        if ($this->request->getPost('password') != "") {
            $data['password'] = password_hash($this->request->getPost('password'), PASSWORD_DEFAULT);
        }

        $this->users->update($id, $data);

        return redirect()->to('/users')->with('success', 'Data user berhasil diupdate!');
    }


    public function delete($id)
    {
        $user = $this->users->find($id);

        // hapus foto jika ada
        if ($user['foto'] && file_exists(FCPATH . 'uploads/users/' . $user['foto'])) {
            unlink(FCPATH . 'uploads/users/' . $user['foto']);
        }

        $this->users->delete($id);

        return redirect()->to('/users')->with('success', 'User berhasil dihapus!');
    }
    // sampai sini

    public function detail($id)
    {
        $user = $this->users->find($id);

        if (!$user) {
            return redirect()->to('/users')->with('error', 'Data tidak ditemukan');
        }

        return view('users/detail', ['user' => $user]);
    }

    public function print()
    {
        $keyword = $this->request->getGet('keyword');
        $role = $this->request->getGet('role');

        $builder = $this->users;

        if ($keyword) {
            $builder = $builder->like('nama', $keyword);
        }

        if ($role) {
            $builder = $builder->where('role', $role);
        }

        $data['users'] = $builder->findAll();

        return view('users/print', $data);
    }

    public function wa($id)
    {
        $user = $this->users->find($id);

        if (!$user) {
            return redirect()->back()->with('error', 'Data tidak ditemukan');
        }

        // format pesan
        $pesan = "DATA USER\n\n";
        $pesan .= "ID: " . $user['id'] . "\n";
        $pesan .= "Nama: " . $user['nama'] . "\n";
        $pesan .= "Email: " . $user['email'] . "\n";
        $pesan .= "Username: " . $user['username'] . "\n";
        $pesan .= "Role: " . ucfirst($user['role']) . "\n";

        // encode URL
        $url = "https://wa.me/6285175017991?text=" . urlencode($pesan);

        return redirect()->to($url);
    }
}
