// Version de solidity
pragma solidity >=0.4.22 <0.7.0;

// Declaracion del Smart Contract - Auction
contract Auction {
    // ----------- Variables (datos) -----------
    // Información de la subasta
    string public description;
    uint256 public basePrice;
    uint256 private secondsToEnd;
    uint256 public createdTime;

    // Antiguo/nuevo dueño de subasta
    address payable public originalOwner;
    address public newOwner;

    // Puja mas alta
    address payable public highestBidder;
    uint256 public highestPrice;

    // Estado de la subasta
    bool public activeContract;

    // ----------- Eventos (pueden ser emitidos por el Smart Contract) -----------
    event Status(string _message);
    event Result(string _message, address winner);

    // ----------- Constructor -----------
    // Uso: Inicializa el Smart Contract - Auction con: description, precio y tiempo
    constructor() public {
        // Inicializo el valor a las variables (datos)
        description = "Subasta de la Gioconda de Leonardo da Vinci";
        basePrice = 1 ether;
        secondsToEnd = 86400;
        activeContract = true;
        createdTime = block.timestamp;
        originalOwner = msg.sender;

        // Se emite un Evento
        emit Status("Subasta abierta");
    }

    // ------------ Funciones que modifican datos (set) ------------

    // Funcion
    // Nombre: bid
    // Uso:    Permite a cualquier postor hacer una oferta de dinero para la subata
    //         El dinero es almacenado en el contrato, junto con el nombre del postor
    //         El postor cuya oferta ha sido superada recibe de vuelta el dinero pujado
    function bid() public payable {
        if (
            block.timestamp > (createdTime + secondsToEnd) &&
            activeContract == true
        ) {
            checkIfAuctionEnded();
        } else {
            if (msg.value > highestPrice && msg.value > basePrice) {
                // Devuelve el dinero al ANTIGUO maximo postor
                highestBidder.transfer(highestPrice);

                // Actualiza el nombre y precio al NUEVO maximo postor
                highestBidder = msg.sender;
                highestPrice = msg.value;

                // Se emite un evento
                emit Status(
                    "Nueva puja mas alta, el ultimo postor recibe de vuelta su dinero"
                );
            } else {
                // Se emite un evento
                emit Status("Puja no válida, no supera el precio mínimo");
                revert();
            }
        }
    }

    // Funcion
    // Nombre: checkIfAuctionEnded
    // Uso:    Comprueba si la puja ha terminado, y en ese caso,
    //         transfiere el balance del contrato al propietario de la subasta
    function checkIfAuctionEnded() public {
        if (block.timestamp > (createdTime + secondsToEnd)) {
            // Finaliza la subasta
            activeContract = false;

            // Transfiere el dinero (maxima puja) al propietario original de la subasta
            newOwner = highestBidder;
            originalOwner.transfer(highestPrice);

            // Se emiten varios eventos
            emit Status("La subasta se ha cerrado");
            emit Result("El ganador de la subasta ha sido:", highestBidder);
        } else {
            revert();
        }
    }

    // ------------ Funciones de panico/emergencia ------------

    // Funcion
    // Nombre: stopAuction
    // Uso:    Para la subasta y devuelve el dinero al maximo postor
    function stopAuction() public {
        require(msg.sender == originalOwner);
        // Finaliza la subasta
        activeContract = false;
        // Devuelve el dinero al maximo postor
        highestBidder.transfer(highestPrice);

        // Se emite un evento
        emit Status("La subasta se cierra");
    }

    // ------------ Funciones que consultan datos (get) ------------

    // Funcion
    // Nombre: getAuctionInfo
    // Logica: Consulta la description, y la fecha de creacion de la subasta
    function getAuctionInfo() public view returns (string memory, uint256) {
        return (description, createdTime);
    }

    // Funcion
    // Nombre: getHighestPrice
    // Logica: Consulta el precio de la maxima puja
    function getHighestPrice() public view returns (uint256) {
        return (highestPrice);
    }
}
