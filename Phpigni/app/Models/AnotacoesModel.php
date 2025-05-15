<?php

namespace App\Models;

use CodeIgniter\Model;

class AnotacoesModel extends Model
{
    protected $table = 'anotacoes';
    protected $allowedFields = ['usuario_uid', 'psicologo_uid', 'titulo', 'conteudo', 'compartilhada'];
    protected $useTimestamps = true; 
    protected $createdField = 'data'; 
}