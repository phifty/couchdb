require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe "user management" do

  before :each do
    @server = CouchDB::Server.new "localhost", 5984, "test", "test"
    @server.password_salt = "salt"

    @user_database = @server.user_database
  end

  describe "creating an user" do

    before :each do
      @user = CouchDB::User.new @user_database, "test_user"
      @user.password = "test"
      @user.roles = [ "dummy" ]
    end

    it "should be indicated by a #save method that returns true" do
      result = @user.save
      result.should be_true
    end

    it "should create the user" do
      @user.save
      @user_database.users.should include(@user)
    end

    it "should store all attributes" do
      @user.save
      @user.load
      @user.name.should == "test_user"
      @user.password.should == "f438229716cab43569496f3a3630b3727524b81b"
      @user.roles.should == [ "dummy" ]
    end

  end

  describe "updating an user" do

    before :each do
      @user = CouchDB::User.new @user_database, "test_user"
      @user.password = "test"
      @user.roles = [ "dummy" ]
      @user.save
      @user.password = "another_test"
    end

    it "should be indicated by a #save method that returns true" do
      result = @user.save
      result.should be_true
    end

    it "should update all attributes" do
      @user.save
      @user.load
      @user.password.should == "9ab52af5e5eb1cac7c2ff6eac610872bf0e6ab5c"
    end

  end

  describe "destroying an user" do

    before :each do
      @user = CouchDB::User.new @user_database, "test_user"
      @user.password = "test"
      @user.roles = [ "dummy" ]
      @user.save
    end

    it "should be indicated by a #destroy method that returns true" do
      result = @user.destroy
      result.should be_true
    end

    it "should remove the user" do
      @user.destroy
      @user_database.users.should_not include(@user)
    end

  end

end
