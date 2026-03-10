CREATE DATABASE IF NOT EXISTS loginDB;
USE loginDB;

CREATE TABLE IF NOT EXISTS utilizador (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    utilizador VARCHAR(50) NOT NULL UNIQUE,
    senha VARCHAR(64) NOT NULL -- SHA2 gera 64 caracteres
);

DELIMITER //

CREATE PROCEDURE registarUtilizador(
    IN p_nome VARCHAR(100),
    IN p_utilizador VARCHAR(50),
    IN p_senha VARCHAR(50),
    OUT mensagem VARCHAR(255)
)
BEGIN
    DECLARE existente INT;

    SELECT COUNT(*) INTO existente
    FROM utilizador
    WHERE utilizador = p_utilizador;

    IF existente > 0 THEN
        SET mensagem = 'Erro: Utilizador já existe!';
    ELSE
        INSERT INTO utilizador (nome, utilizador, senha)
        VALUES (p_nome, p_utilizador, SHA2(p_senha, 256));

        SET mensagem = 'Utilizador registado com sucesso!';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE loginUtilizador(
    IN p_utilizador VARCHAR(50),
    IN p_senha VARCHAR(50),
    OUT mensagem VARCHAR(255)
)
BEGIN
    DECLARE senha_bd VARCHAR(64);

    -- Busca a senha do utilizador
    SELECT senha INTO senha_bd
    FROM utilizador
    WHERE utilizador = p_utilizador;

    
    IF senha_bd IS NULL THEN
        SET mensagem = 'Erro: Utilizador não existe!';
    ELSE
        
        IF SHA2(p_senha, 256) = senha_bd THEN
            SET mensagem = 'Login bem-sucedido!';
        ELSE
            SET mensagem = 'Erro: Senha incorreta!';
        END IF;
    END IF;
END //

DELIMITER ;

-- Testando

-- Variável para armazenar mensagem
SET @msg = '';

-- Registar um utilizador
CALL registarUtilizador('Erasmo Veloso', 'erasmo', '123456', @msg);
SELECT @msg;  -- Deve mostrar "Utilizador registado com sucesso!"

-- Tentar fazer login
CALL loginUtilizador('erasmo', '123456', @msg);
SELECT @msg;  -- Deve mostrar "Login bem-sucedido!"

-- Login com senha errada
CALL loginUtilizador('erasmo', 'senhaerrada', @msg);
SELECT @msg;  -- Deve mostrar "Erro: Senha incorreta!"