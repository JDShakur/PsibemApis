<?php

namespace App\Controllers;

use App\Models\Psicologos;
use CodeIgniter\API\ResponseTrait;
use App\Models\Usuarios;
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
class AuthController extends BaseController
{
    use ResponseTrait;

    public function registerPsi()
    //register-psi para inserir dados dos psicologos
    {
        // Recebe os dados do Flutter
        $data = $this->request->getJSON(true);

        // Valida os dados (opcional)
        if (empty($data['uid']) || empty($data['email'])) {
            return $this->failValidationErrors('Dados inválidos.');
        }
        $data['data'] = date('Y-m-d', strtotime($data['data']));

 
        $model = new Psicologos();
        $model->save([
            'uid'   => $data['uid'],
            'email' => $data['email'],
            'apelido'=> $data['apelido'],
            'crp'   => $data['crp'],
            'nome'  => $data['nome'],
            'telefone' => $data['telefone'],
            'data'  => $data['data'],
            'sexo'  => $data['sexo'],
        ]);

        // Retorna uma resposta de sucesso
        return $this->respondCreated(['message' => 'Psicólogo cadastrado com sucesso.']);
    }

    public function registerUser()
{
    $data = $this->request->getJSON(true);

    if (empty($data['uid']) || empty($data['email'])) {
        return $this->failValidationErrors('Dados inválidos.');
    }

    $model = new Usuarios();
    
    // Hash da senha
    $hashedPassword = password_hash($data['password'], PASSWORD_BCRYPT);
    
    $model->save([
        'uid' => $data['uid'],
        'email' => $data['email'],
        'password_hash' => $hashedPassword, 
        'apelido' => $data['apelido'] ?? '',
        'nome' => $data['nome'] ?? '',
        'telefone' => $data['telefone'] ?? '',
        'data' => $data['data'] ?? null,
        'sexo' => $data['sexo'] ?? '',
    ]);

    return $this->respondCreated(['message' => 'Usuário cadastrado com sucesso.']);
}

    public function updatePsi()
    {
        // Recebe os dados do Flutter
        $data = $this->request->getJSON(true);
    
        // Valida os dados (opcional)
        if (empty($data['uid'])) {
            return $this->failValidationErrors('UID é obrigatório.');
        }
    
        // Busca o psicólogo pelo UID
        $model = new Psicologos();
        $psi = $model->where('uid', $data['uid'])->first();
    
        if (!$psi) {
            return $this->failNotFound('Psicólogo não encontrado.');
        }
    
        // Atualiza os dados
        $model->update($psi['id'], [
            'Email'    => $data['email'] ?? $psi['email'],
            'apelido' => $data['apelido'] ?? $psi['apelido'],
            'crp'     => $data['crp'] ?? $psi['crp'],
            'nome'    => $data['nome'] ?? $psi['nome'],
            'telefone' => $data['telefone'] ?? $psi['telefone'],
            'data'    => !empty($data['data']) ? date('Y-m-d', strtotime($data['data'])) : $psi['data'],
            'sexo'    => $data['sexo'] ?? $psi['sexo'],
        ]);
    
        // Retorna uma resposta de sucesso
        return $this->respond(['message' => 'Psicólogo atualizado com sucesso.']);
    }

    public function updateUser()
    {
        
        // Recebe os dados do Flutter
        $data = $this->request->getJSON(true);
        
        // Valida os dados
        if (empty($data['uid'])) {
            log_message('error', 'UID não fornecido');
            return $this->failValidationErrors('UID é obrigatório.');
        }
        
        // Busca o usuário pelo UID
        $model = new Usuarios();
        $user = $model->where('uid', $data['uid'])->first();
        
        if (!$user) {
            log_message('error', 'Usuário não encontrado para UID: ' . $data['uid']);
            return $this->failNotFound('Usuário não encontrado.');
        }
        
        // Prepara dados para atualização
        $updateData = [
            'email'    => $data['email'] ?? $user['email'],
            'apelido'  => $data['apelido'] ?? $user['apelido'],
            'nome'     => $data['nome'] ?? $user['nome'],
            'telefone' => $data['telefone'] ?? $user['telefone'],
            'data'     => !empty($data['data']) ? date('Y-m-d', strtotime($data['data'])) : $user['data'],
            'sexo'     => $data['sexo'] ?? $user['sexo'],
        ];
        
        log_message('info', 'Dados para atualização: ' . print_r($updateData, true));
        
        // Atualiza os dados
        try {
            $result = $model->update($user['id'], $updateData);
            log_message('info', 'Resultado da atualização: ' . ($result ? 'sucesso' : 'falha'));
            
            // Verifica se realmente foi atualizado
            $updatedUser = $model->find($user['id']);
            log_message('info', 'Dados após atualização: ' . print_r($updatedUser, true));
            
            return $this->respond(['message' => 'Usuário atualizado com sucesso.']);
        } catch (\Exception $e) {
            log_message('error', 'Erro ao atualizar usuário: ' . $e->getMessage());
            return $this->failServerError('Erro ao atualizar usuário.');
        }
    }

    //<--- em testes
    public function checkPsi()
    {
        // Recebe os dados do Flutter
        $data = $this->request->getJSON(true);
    
        // Valida os dados (opcional)
        if (empty($data['uid']) && empty($data['email'])) {
            return $this->failValidationErrors('UID ou email é obrigatório.');
        }
    
        // Busca o psicólogo pelo UID ou email
        $model = new Psicologos();
        $psi = $model->where('uid', $data['uid'])->orWhere('email', $data['email'])->first();
    
        if ($psi) {
            return $this->respond(['exists' => true, 'data' => $psi]);
        } else {
            return $this->respond(['exists' => false]);
        }
    }

    public function checkUser()
    {
        // Recebe os dados do Flutter
        $data = $this->request->getJSON(true);
    
        // Valida os dados (opcional)
        if (empty($data['uid']) && empty($data['email'])) {
            return $this->failValidationErrors('UID ou email é obrigatório.');
        }
    
        // Busca o usuário pelo UID ou email
        $model = new Usuarios();
        $user = $model->where('uid', $data['uid'])->orWhere('email', $data['email'])->first();
    
        if ($user) {
            return $this->respond(['exists' => true, 'data' => $user]);
        } else {
            return $this->respond(['exists' => false]);
        }
    }
    public function toggleUserStatus($id)
{
    // Busca o usuário pelo ID
    $model = new Usuarios();
    $user = $model->find($id);

    if (!$user) {
        return $this->failNotFound('Usuário não encontrado.');
    }

    // Alterna o status (ativo/desativado)
    $novoStatus = $user['ativo'] ? 0 : 1;

    // Atualiza o status no banco de dados
    $model->update($id, ['ativo' => $novoStatus]);

    // Retorna uma resposta de sucesso
    return $this->respond(['message' => 'Status do usuário atualizado com sucesso.', 'ativo' => $novoStatus]);
}
public function togglePsiStatus($id)
{
    // Busca o psicólogo pelo ID
    $model = new Psicologos();
    $psi = $model->find($id);

    if (!$psi) {
        return $this->failNotFound('Psicólogo não encontrado.');
    }

    // Alterna o status (ativo/desativado)
    $novoStatus = $psi['ativo'] ? 0 : 1;

    // Atualiza o status no banco de dados
    $model->update($id, ['ativo' => $novoStatus]);

    // Retorna uma resposta de sucesso
    return $this->respond(['message' => 'Status do psicólogo atualizado com sucesso.', 'ativo' => $novoStatus]);
}
public function deleteUser()
{
    // Recebe os dados do Flutter
    $data = $this->request->getJSON(true);

    // Valida os dados
    if (empty($data['uid'])) {
        return $this->failValidationErrors('UID é obrigatório.');
    }

    // Busca e exclui o usuário
    $model = new Usuarios();
    $user = $model->where('uid', $data['uid'])->first();

    if (!$user) {
        return $this->failNotFound('Usuário não encontrado.');
    }

    $model->delete($user['id']);

    return $this->respond(['message' => 'Usuário excluído com sucesso.']);
}

public function getUserByUid($uid)
{
    $model = new Usuarios();
    $user = $model->where('uid', $uid)->first();

    if (!$user) {
        return $this->failNotFound('Usuário não encontrado.');
    }

    return $this->respond($user);
}
public function updatePassword()
{
    $data = $this->request->getJSON(true);

    // Validação
    if (empty($data['uid']) || empty($data['new_password'])) {
        return $this->failValidationErrors('Dados inválidos.');
    }

    $model = new Usuarios();
    $user = $model->where('uid', $data['uid'])->first();

    if (!$user) {
        return $this->failNotFound('Usuário não encontrado.');
    }

    // Atualiza a senha com hash seguro
    $hashedPassword = password_hash($data['new_password'], PASSWORD_BCRYPT);
    
    $model->update($user['id'], [
        'password_hash' => $hashedPassword
    ]);

    return $this->respond(['message' => 'Senha atualizada com sucesso.']);
}
}
    