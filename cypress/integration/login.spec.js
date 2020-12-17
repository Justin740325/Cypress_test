context('login', () => {
    beforeEach(() => {
      cy.fixture('account').then(function (data) {
        this.accounts = data;
      });
    })

    function inputAccount (data){
      cy.get('input[formcontrolname="account"]').clear().type(data);
    }
    function inputPassword (data){
      cy.get('input[formcontrolname="password"]').clear().type(data);
    }
    function btnClick (){
      cy.get('button').click();
    }

    it('檢查 url', function() {
      cy.visit('/');

      cy.url().should('include', '/auth/login');
    })


    it('沒輸入密碼', function() {
      cy.visit('/auth/login');
      inputAccount(this.accounts.admin.account);
      btnClick();

      cy.get('uof-form-error-tip >div').should('exist');
    })

    it('密碼錯誤', function() {
      inputAccount(this.accounts.admin.account);
      inputPassword('111');
      btnClick();

      cy.get('.e-error').should('exist');
    })


    it('登入成功', function() {
      inputAccount(this.accounts.admin.account);
      inputPassword(this.accounts.admin.password);
      btnClick();

      cy.get('uof-empty')
        .should('exist');

      // cy.get('user-header-component')
      //   .should('exist')

      // cy.url()
      //   .should('include', '/dashboard');
    })
    
})
