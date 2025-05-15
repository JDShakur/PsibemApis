<?php

namespace App\Models;

use CodeIgniter\Model;

class Psicologos extends Model
{
    protected $table = 'psicologos';
    protected $primaryKey = 'id';
    protected $allowedFields = ['uid', 'email', 'crp', 'nome', 'telefone', 'data', 'sexo','apelido', 'created_at', 'updated_at','ativo'];
    protected $useTimestamps = true;
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';
}