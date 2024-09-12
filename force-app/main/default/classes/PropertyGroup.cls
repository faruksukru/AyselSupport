public class PropertyGroup {
    @AuraEnabled public String email { get; set; }
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public List<Account> accountList { get; set; }
    
    public PropertyGroup(String email, String name, List<Account> accountList) {
        this.email = email;
        this.name = name;
        this.accountList = accountList;
    }
    // Default no-arg constructor for Flow usage
    public PropertyGroup() {}
}