<?php

namespace App\Controllers;

use App\Models\AnotacoesModel;
use CodeIgniter\API\ResponseTrait;

class DiarioController extends BaseController
{
    use ResponseTrait;

   
    public function salvarAnotacao()
    {
     
        $data = $this->request->getJSON(true);

      
        if (empty($data['usuario_uid']) || empty($data['titulo']) || empty($data['conteudo'])) {
            return $this->failValidationErrors('Dados inválidos.');
        }

     
        $model = new AnotacoesModel();
        $model->save([
            'usuario_uid' => $data['usuario_uid'],
            'titulo' => $data['titulo'],
            'conteudo' => $data['conteudo'],
            'compartilhada' => false, 
        ]);

       
        return $this->respondCreated(['message' => 'Anotação salva com sucesso.']);
    }

  
    public function compartilharAnotacao()
    {
        
        $data = $this->request->getJSON(true);

        
        if (empty($data['anotacao_id']) || empty($data['psicologo_uid'])) {
            return $this->failValidationErrors('Dados inválidos.');
        }

      
        $model = new AnotacoesModel();
        $model->update($data['anotacao_id'], [
            'psicologo_uid' => $data['psicologo_uid'],
            'compartilhada' => true,
        ]);

       
        return $this->respond(['message' => 'Anotação compartilhada com sucesso.']);
    }

    
    public function listarAnotacoes($usuario_uid)
    {
        $model = new AnotacoesModel();
        $anotacoes = $model->where('usuario_uid', $usuario_uid)->findAll();
        return $this->respond($anotacoes);
    }
}