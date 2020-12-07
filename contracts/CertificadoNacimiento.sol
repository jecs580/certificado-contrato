pragma solidity ^0.5.0;
import "./ownable.sol";
contract CertificadoNacimiento is Ownable{
    
    // Variables
    
    // Estructuras
    struct Certificado{
        // ubicacion
        string departamento;  // departamento provincia localidad
        // string provincia;
        // string localidad;
        // string localidad_emision;
        
        // date
        uint256 fecha; // timestamp
        // uint256 fecha_emision;
        //usuario
        string nombre; // Nombre completo
        string departamento_nacimiento; // departamento provincia localidad
        // string provincia_nacimiento;
        // string localidad_nacimiento;
        uint256 fecha_naciminto; // timestamp
        bool sexo; // 0:masculino, 1:femenino
        string nombre_padre; // Nombre completo
        string nombre_madre; // Nombre completo
        bool active;
        // address notario;
    }
    struct Complemento{
        uint256 oficialia;
        string libro;
        uint256 partida;
        uint256 folio;
        string serie;
        string nota_aclaratoria;
    }
    struct Usuario{
        string nombre; // Nombre completo
        address direccion;
        string role;
        string email;
        uint32 listSizeInstituciones;
    }
    struct Instituto{
        address direccion;
        string nombre;
        string telefono;
        string email;
        bool verified;
        uint256 listSizeCertificados;
    }
    
    Certificado [] public certificados;
    address constant internal FIRST_ADDRESS = address(1);
    uint256 public countCert;
    // Diccionarios
    mapping(uint256 => Complemento) public complementos;
    mapping(address=>Usuario) public usuarios;
    mapping(address=>Instituto) public institutos;
    mapping(uint256 => address) public certifcadoToOwner;
    mapping(uint256 => address) public certifiedCreator; // Address del creador del certificado(Notario)
    
    mapping(uint256 => mapping(address=> address)) internal listaInstitucionesXCertificado;
    mapping(address => mapping(address=> address)) internal listaCertificadosXInstituciones;
    
    
    
    // Eventos
    event newCertificado(uint certificadoId, string nombre, address notario);
    // event newUsuario(string nombre, address notario);
    // event newInstituto(string nombre, address instituto);
    // event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    // Modificadores
    modifier onlyNotario(address _direccion) {
        string memory role = usuarios[_direccion].role;
        require(keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("notario")),"La direccion no pertenece a un notario");
        _;
    }
    modifier onlyOwnerCertificate(uint256 _certificadoId, address _direccion){
        require(certifcadoToOwner[_certificadoId] == _direccion,"El certificado no pertence a la direccion enviada");
        _;
    }
    modifier onlyUserbyAddress(address _direccion){
        require(usuarios[_direccion].direccion==address(0),"La direccion ya tiene una cuenta de usuario");
        _;
    }
    modifier onlyInstitutoByAddress(address _direccion){
        require(usuarios[_direccion].direccion==address(0),"La direccion ya tiene una cuenta de usuario");
        require(institutos[_direccion].direccion==address(0),"La direccion ya tiene una cuenta de instituto");
        _;
    }
    modifier onlyUser(address _direccion){
        require(usuarios[_direccion].direccion==_direccion,"La direccion no pertenece a un usuario");
        _;
    }
    modifier onlyInstituto(address _direccion){
        require(institutos[_direccion].direccion==_direccion,"La direccion no pertenece a un instituto");
        _;
    }
    
    // Constructor
    constructor() public {
         Certificado memory nCertificado;
         certificados.push(nCertificado);
    }
    
    // Metodos
    function createUser(string memory _nombre, string memory _email) public onlyUserbyAddress(msg.sender){
        Usuario memory n_user;
        n_user.nombre = _nombre;
        n_user.role = "usuario";
        n_user.direccion = msg.sender;
        n_user.email = _email;
        n_user.listSizeInstituciones=0;
        usuarios[msg.sender]=n_user;
        // emit newUsuario(_nombre,msg.sender);
    }
    
    function crearInstituto(string memory _nombre,string memory _telefono,string memory _email) public onlyInstitutoByAddress(msg.sender){
         Instituto memory n_instituto;
         n_instituto.direccion = msg.sender;
         n_instituto.nombre = _nombre;
         n_instituto.telefono = _telefono;
         n_instituto.email = _email;
         n_instituto.verified = false;
         n_instituto.listSizeCertificados=0;
         institutos[msg.sender] = n_instituto;
         
         listaCertificadosXInstituciones[msg.sender][FIRST_ADDRESS]=FIRST_ADDRESS;
        //  emit newInstituto(_nombre,msg.sender);
    }
    
    function createCertificado(string memory _departamento,uint256 _fecha,string memory _nombre,
    string memory _departamento_nacimiento, uint256 _fecha_nacimiento,bool _sexo,
    string memory _nombre_padre,string memory _nombre_madre) public onlyNotario(msg.sender){
        Certificado memory nCertificado;
        nCertificado.departamento =_departamento;
        nCertificado.fecha = _fecha;
        nCertificado.nombre = _nombre;
        nCertificado.departamento_nacimiento = _departamento_nacimiento;
        nCertificado.fecha_naciminto = _fecha_nacimiento;
        nCertificado.sexo = _sexo;
        nCertificado.nombre_padre = _nombre_padre;
        nCertificado.nombre_madre = _nombre_madre;
        certificados.push(nCertificado);
        certifcadoToOwner[certificados.length - 1] = msg.sender;
        countCert++;
        certifiedCreator[certificados.length -1] =  msg.sender;
        
        listaInstitucionesXCertificado[certificados.length - 1][FIRST_ADDRESS]=FIRST_ADDRESS;
        emit newCertificado(certificados.length -1, _nombre,msg.sender);
    }
    
    function crearComplemento(uint256 _oficialia,string memory _libro, uint256 _partida, 
    uint256 _folio,string memory _serie,string memory _nota_aclaratoria,uint256 _certificadoId) public onlyNotario(msg.sender){
        Complemento memory nComplemento;
        nComplemento.oficialia = _oficialia;
        nComplemento.libro = _libro;
        nComplemento.partida = _partida;
        nComplemento.folio = _folio;
        nComplemento.serie = _serie;
        nComplemento.nota_aclaratoria = _nota_aclaratoria;
        complementos[_certificadoId]= nComplemento;
    }

    function setUser(string memory _nombre, string memory _email) public onlyUser(msg.sender){
        Usuario storage n_user = usuarios[msg.sender];
        n_user.nombre = _nombre;
        n_user.email = _email;
    }
    
    function setInstitucion(string memory _nombre,string memory _telefono,string memory _email) public onlyInstituto(msg.sender){
         Instituto storage n_instituto=institutos[msg.sender];
         n_instituto.nombre = _nombre;
         n_instituto.telefono = _telefono;
         n_instituto.email = _email;
    }
    
    // function setCertificate(uint256 _certificadoId,string memory _departamento,uint256 _fecha,string memory _nombre,
    // string memory _departamento_nacimiento, uint256 _fecha_nacimiento,bool _sexo,
    // string memory _nombre_padre,string memory _nombre_madre) public onlyNotario(msg.sender){
    //     Certificado storage nCertificado = certificados[_certificadoId];
    //     nCertificado.departamento =_departamento;
    //     nCertificado.fecha = _fecha;
    //     nCertificado.nombre = _nombre;
    //     nCertificado.departamento_nacimiento = _departamento_nacimiento;
    //     nCertificado.fecha_naciminto = _fecha_nacimiento;
    //     nCertificado.sexo = _sexo;
    //     nCertificado.nombre_padre = _nombre_padre;
    //     nCertificado.nombre_madre = _nombre_madre;
    // }

    function roleNotario(address _direccion)public onlyOwner{
        Usuario storage notario = usuarios[_direccion];
        notario.role="notario";
    }
    
    function setValidarInstitucion(address _direccion,bool valor) public onlyNotario(msg.sender){
        Instituto storage instituto = institutos[_direccion];
        instituto.verified=valor;
    }
    
    function setActive(uint256 _certificadoId, bool _active) public onlyNotario(msg.sender){
        Certificado storage _certificado = certificados[_certificadoId];
        _certificado.active = _active;
    }
    
    function getCertificadoByOwner(address _owner) public view returns(uint256,bool) {
        uint256 resultado = 0;
        bool valido = false;
        for (uint i = 0; i < certificados.length; i++) {
          if (certifcadoToOwner[i] == _owner) {
            resultado = i;
            valido = true;
          }
        }
        return (resultado,valido);
    }
    
    function transferCertificado(address _newOwner,uint256 _certificadoId) public onlyNotario(msg.sender) {
        require(_newOwner != address(0),"La nueva direccion es válida");
        Certificado storage _certificado = certificados[_certificadoId];
        _certificado.active = true;
        certifcadoToOwner[_certificadoId]= _newOwner;
        
        // emit OwnershipTransferred(owner, _newOwner);
    }
    
    function compartirCertificado(uint256 _certificadoId, address _institucion) public onlyOwnerCertificate(_certificadoId,msg.sender){
     require(certificados[_certificadoId].active==true,"El certificado no esta activo");
     require(institutos[_institucion].verified==true, "La institucion no esta verificada");
      addListCertificado(_institucion,_certificadoId);
      
    //   ownerToCerfificado[owner] =_certificadoId;
      addListInstitucion(certifcadoToOwner[_certificadoId],_institucion);
    }
    
    function desCompartirCertificado(uint256 _certificadoId, address _institucion) public{
        removeListCertificado(_institucion,_certificadoId);
        
        address owner = certifcadoToOwner[_certificadoId];
        removeListInstitucion(owner,_institucion);
    }
    
    function isInListCertificado(address _address,uint256 _certificadoId) view internal returns(bool){
        return listaInstitucionesXCertificado[_certificadoId][_address] != address(0);
    }
    
    function isInListInstituciones(address _address,address _addressInstituto) view internal returns(bool){
        return listaCertificadosXInstituciones[_addressInstituto][_address] != address(0);
    }
    
    function getPrevCertificado(address _address,uint256 _certificadoId) view internal returns(address){
        address currentAddress = FIRST_ADDRESS;
        while(listaInstitucionesXCertificado[_certificadoId][currentAddress]!= FIRST_ADDRESS){
            if(listaInstitucionesXCertificado [_certificadoId][currentAddress] == _address){
                return currentAddress;
            }
            currentAddress=listaInstitucionesXCertificado[_certificadoId][currentAddress];
        }
        return FIRST_ADDRESS;
    }
    
    function getPrevInstitucion(address _address,address _addressInstituto) view internal returns(address){
        address currentAddress = FIRST_ADDRESS;
        while(listaCertificadosXInstituciones[_addressInstituto][currentAddress]!= FIRST_ADDRESS){
            if(listaCertificadosXInstituciones[_addressInstituto][currentAddress] == _address){
                return currentAddress;
            }
            currentAddress=listaCertificadosXInstituciones[_addressInstituto][currentAddress];
        }
        return FIRST_ADDRESS;
    }
    
    function addListCertificado(address _address,uint256 _certificadoId) internal {
        require(!isInListCertificado(_address,_certificadoId));
        listaInstitucionesXCertificado[_certificadoId][_address]=listaInstitucionesXCertificado[_certificadoId][FIRST_ADDRESS];
        listaInstitucionesXCertificado[_certificadoId][FIRST_ADDRESS]=_address;
        address user_address = certifcadoToOwner[_certificadoId];
        Usuario storage user = usuarios[user_address];
        user.listSizeInstituciones++;
    }
    
    function addListInstitucion(address _address,address _addressInstituto) internal {
        require(!isInListInstituciones(_address,_addressInstituto));
        listaCertificadosXInstituciones[_addressInstituto][_address]=listaCertificadosXInstituciones[_addressInstituto][FIRST_ADDRESS];
        listaCertificadosXInstituciones[_addressInstituto][FIRST_ADDRESS]=_address;
        Instituto storage instituto = institutos[_addressInstituto];
        instituto.listSizeCertificados++;
    }
    
    function removeListCertificado(address _address,uint256 _certificadoId) internal {
        require(isInListCertificado(_address,_certificadoId));
        address prevUser = getPrevCertificado(_address,_certificadoId);
        listaInstitucionesXCertificado[_certificadoId][prevUser]= listaInstitucionesXCertificado[_certificadoId][_address];
        listaInstitucionesXCertificado[_certificadoId][_address]=address(0);
        address user_address = certifcadoToOwner[_certificadoId];
        Usuario storage user = usuarios[user_address];
        user.listSizeInstituciones --;
    }
    
    function removeListInstitucion(address _address,address _addressInstituto) internal {
        require(isInListInstituciones(_address,_addressInstituto));
        address prevUser = getPrevInstitucion(_address,_addressInstituto);
        listaCertificadosXInstituciones[_addressInstituto][prevUser]= listaCertificadosXInstituciones[_addressInstituto][_address];
        listaCertificadosXInstituciones[_addressInstituto][_address]=address(0);
        Instituto storage instituto = institutos[_addressInstituto];
        instituto.listSizeCertificados --;
    }
    
    function listarInstituciones(uint256 _certificadoId) view public returns(address[] memory){
        address user_address = certifcadoToOwner[_certificadoId];
        Usuario memory user = usuarios[user_address];
        address [] memory usersArray = new address[](user.listSizeInstituciones);
        address currentAddress =  listaInstitucionesXCertificado[_certificadoId][FIRST_ADDRESS];
        for(uint256 i =0; i<user.listSizeInstituciones;i++){
            usersArray[i]=currentAddress;
            currentAddress=listaInstitucionesXCertificado[_certificadoId][currentAddress];
        }
        return usersArray;
    }
    
    function listarCertitificados(address _addressInstituto) view public returns(uint256[] memory){
        Instituto memory instituto = institutos[_addressInstituto];
        uint256 [] memory usersArray = new uint256[](instituto.listSizeCertificados);
        address currentAddress =  listaCertificadosXInstituciones[_addressInstituto][FIRST_ADDRESS];
        for(uint256 i =0; i<instituto.listSizeCertificados;i++){
            // usersArray[i]=ownerToCerfificado[currentAddress];
            (uint256 certificadoId,) = getCertificadoByOwner(currentAddress);
            usersArray[i]=certificadoId;
            currentAddress=listaCertificadosXInstituciones[_addressInstituto][currentAddress];
        }
        return usersArray;
    }
}
