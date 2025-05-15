<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->group('api', ['namespace' => 'App\Controllers'], function(RouteCollection $routes) {
    // Rota para registrar um psicólogo
    $routes->post('register-psi', 'AuthController::registerPsi');
    
    // Rota para registrar um usuário comum
    $routes->post('register-user', 'AuthController::registerUser');   
    //Rotas de anotações
    $routes->post('salvar-anotacao', 'DiarioController::salvarAnotacao');
    $routes->post('compartilhar-anotacao', 'DiarioController::compartilharAnotacao');
    $routes->get('listar-anotacoes/(:segment)', 'DiarioController::listarAnotacoes/$1');
    //rotas crud
    //update
    $routes->post('update-psi', 'AuthController::updatePsi');
    $routes->post('update-user', 'AuthController::updateUser');
    //update senha
    $routes->post('update-password', 'AuthController::updatePassword');
    //verificar
    $routes->post('check-psi', 'AuthController::checkPsi');
    $routes->post('check-user', 'AuthController::checkUser');
    $routes->get('getUserByUid/(:any)', 'AuthController::getUserByUid/$1');
    //delete 
    $routes->put('user-status/(:num)', 'AuthController::toggleUserStatus/$1');
    $routes->put('psi-status/(:num)', 'AuthController::togglePsiStatus/$1');
    $routes->post('deleteUser', 'AuthController::deleteUser');
    
});
