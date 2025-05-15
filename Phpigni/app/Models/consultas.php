<?php

namespace App\Models;

use CodeIgniter\Model;

class Consultas extends Model
{
    protected $table      = 'consultas'; 
    protected $primaryKey = 'id';        

    // Campos que podem ser preenchidos
    protected $allowedFields = [
        'psicologo_id',
        'usuario_id',
        'data_consulta',
        'status'
    ];

    // Usar timestamps (created_at, updated_at)
    protected $useTimestamps = true;

    // Formato de data
    protected $dateFormat = 'datetime';
}