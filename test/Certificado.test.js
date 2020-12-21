const CertificadoNacimiento = artifacts.require('./CertificadoNacimiento.sol')

contract('CertificadoNacimiento',(accounts)=>{
    before(async()=>{
        this.certificado= await CertificadoNacimiento.deployed()
    })

    it('Despliegue exitoso', async () => {
        const address = await this.certificado.address
        assert.notEqual(address, 0x0)
        assert.notEqual(address, '')
        assert.notEqual(address, null)
        assert.notEqual(address, undefined)
    })
    it('Crear usuarios', async () => {
        
        const result = await this.certificado.createUser('Anabel Torrez','anatorrez@gmail.com')
        const from = await result.receipt.from.toLowerCase();
        let cuentas = await web3.eth.getAccounts();
        const user = await this.certificado.usuarios(cuentas[0])
        assert.equal(from,user.direccion.toLowerCase(),'Coinciden las cuentas')
    })
    it("lanza una excepción para crear usuario con una cuenta existente", async()=> {
        this.certificado.createUser('jorge','jorge-callisaya@gmail.com')
        .then(assert.fail)
        .catch(error=> {
            assert(error.message.indexOf('revert') >= 0, "el mensaje de error debe contener 'revert'");
          })
        let cuentas = await web3.eth.getAccounts();
        const result = await this.certificado.createUser('jorge','jorge-callisaya@gmail.com',{ from: cuentas[1] })
        const from = await result.receipt.from.toLowerCase();
        const user = await this.certificado.usuarios(cuentas[1])
        assert.equal(from,user.direccion.toLowerCase(),'Coinciden las cuentas')
    });
    it('Crear institucion', async () => {
        let cuentas = await web3.eth.getAccounts();
        const result = await this.certificado.crearInstituto('Colegio Pedro Poveda','77599901','pedro.poveda@gmail.com',{ from: cuentas[2] })
        const from = await result.receipt.from.toLowerCase();
        const institucion = await this.certificado.institutos(cuentas[2])
        assert.equal(from,institucion.direccion.toLowerCase(),'Coinciden las cuentas para el nuevo usuario')
    })
    it("lanza excepción para crear institucion con una cuenta de usuario", async()=> {
        this.certificado.crearInstituto('Universidad Mayor de San Andres','73728991','dtic@umsa.bo')
        .then(assert.fail)
        .catch(error=> {
            assert(error.message.indexOf('revert') >= 0, "el mensaje de error debe contener 'revert'");
          })
    });
    it("lanza excepción para crear institucion con una cuenta de existente de institucion", async()=> {
        let cuentas = await web3.eth.getAccounts();
        this.certificado.crearInstituto('Universidad Mayor de San Andres','73728991','dtic@umsa.bo',{ from: cuentas[2] })
        .then(assert.fail)
        .catch(error=> {
            assert(error.message.indexOf('revert') >= 0, "el mensaje de error debe contener 'revert'");
          })
        const result = await this.certificado.crearInstituto('Universidad Mayor de San Andres','73728991','dtic@umsa.bo',{ from: cuentas[3] })
        const from = await result.receipt.from.toLowerCase();
        const institucion = await this.certificado.institutos(cuentas[3])
        assert.equal(from,institucion.direccion.toLowerCase(),'Coinciden las cuentas para la nueva institucion')
    });
    it("lanza excepción para dar rol de notario", async()=> {
        let cuentas = await web3.eth.getAccounts();
        this.certificado.roleNotario(cuentas[1],{ from: cuentas[1] })
        .then(()=>{
            console.log('valido');
        })
        .catch(error=> {
            assert(error.message.indexOf('revert') >= 0, "el mensaje de error debe contener 'revert'");
          })
    });
    it('Crear certificado', async () => {
        let cuentas = await web3.eth.getAccounts();
        await this.certificado.roleNotario(cuentas[0],{ from: cuentas[0] });
        await this.certificado.createCertificado("La Paz Murillo Nuestra Señora de La Paz", 1606434462,"Jorge Enrique Callisaya Sanchez", "La Paz Murillo Nuestra Señora de La Paz", 841708062, false, "Enrique Callisaya Ali", "Candelaria Sanchez Vargas",{ from: cuentas[0] })
        const cuenta = await this.certificado.countCert();
        const certificado = await this.certificado.certificados(cuenta);
        assert.equal(cuenta,1,'El número de certificados aumenta a 1')
        assert.equal(certificado.active,false,'El certificado creado debe estar inactivo')
    })
    it('Verificar institucion',async()=>{
        let cuentas = await web3.eth.getAccounts();
        await this.certificado.setValidarInstitucion(cuentas[2],true,{ from: cuentas[0]})
        const result = await this.certificado.institutos(cuentas[2])
        assert.equal(result.verified,true,'El campo verified debe estar en true')
    })
    it('transferir certificado', async () => {
        let cuentas = await web3.eth.getAccounts();
        const countCertificados = await this.certificado.countCert();
        await this.certificado.transferCertificado(cuentas[1],countCertificados)
        const result = await this.certificado.getCertificadoByOwner(cuentas[1])
        assert.equal(result[0].toNumber(),countCertificados.toNumber(),'El id del certificado coincide con el transferido')
        assert.equal(result[1],true,'El certificado debe ser valido')
    })
    it('Compartir certificado', async () => {
        let cuentas = await web3.eth.getAccounts();
        const countCertificados = await this.certificado.countCert();
        await this.certificado.compartirCertificado(countCertificados,cuentas[2],{ from: cuentas[1] })
        const listInstituciones = await this.certificado.listarInstituciones(countCertificados)
        const listCertificados = await this.certificado.listarCertitificados(cuentas[2])
        assert.equal(listInstituciones[0],cuentas[2],'La primera direccion compartida debe ser la misma que se compartio')
        assert.equal(listCertificados[0].toNumber(),countCertificados.toNumber(),'El primer id de la lista debe ser el mismo que se compartio')
    })
    it('Dejar de compartir certificado', async () => {
        let cuentas = await web3.eth.getAccounts();
        const countCertificados = await this.certificado.countCert();
        await this.certificado.desCompartirCertificado(countCertificados,cuentas[2],{ from: cuentas[1] })
        const listInstituciones = await this.certificado.listarInstituciones(countCertificados)
        const listCertificados = await this.certificado.listarCertitificados(cuentas[2])
        assert.equal(listInstituciones.length,0,'La longitud de la lista de instituciones compartidas debe ser cero')
        assert.equal(listCertificados.length,0,'La longitud de la lista de certificados compartidas debe ser cero')
    })
})