require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe "database security" do

  before :each do
    @server = make_test_server
    @server.password_salt = "salt"

    @user_database = @server.user_database

    @user = CouchDB::User.new @user_database, "test_user"
    @user.password = "test"
    @user.roles = [ "dummy" ]
    @user.save

    @database = make_test_database @server
    @database.delete_if_exists!
    @database.create_if_missing!
    @database.security.administrators.clear!
    @database.security.readers.clear!

    @design = CouchDB::Design.new @database, "test"
    @design.save
  end

  describe "adding an user to the database administrators" do

    before :each do
      @database.security.administrators << @user
      @database.security.save

      @server.username = "test_user"
      @server.password = "test"
    end

    it "should allow the user to manipulate the database content" do
      result = @design.save
      result.should be_true
    end

  end

  describe "adding an user to the database readers" do

    before :each do
      @database.security.readers << @user
      @database.security.save

      @server.username = "test_user"
      @server.password = "test"
    end

    it "should allow the user to read the database content" do
      result = @design.load
      result.should be_true
    end

    it "should deny the user to manipulate the database content" do
      lambda do
        @design.save
      end.should raise_error(CouchDB::Document::UnauthorizedError)
    end

  end

  describe "adding a role to the database administrators" do

    before :each do
      @database.security.administrators << "dummy"
      @database.security.save

      @server.username = "test_user"
      @server.password = "test"
    end

    it "should allow the user to manipulate the database content" do
      result = @design.save
      result.should be_true
    end

  end

  describe "adding a role to the database readers" do

    before :each do
      @database.security.readers << "dummy"
      @database.security.save

      @server.username = "test_user"
      @server.password = "test"
    end

    it "should allow the user to read the database content" do
      result = @design.load
      result.should be_true
    end

    it "should deny the user to manipulate the database content" do
      lambda do
        @design.save
      end.should raise_error(CouchDB::Document::UnauthorizedError)
    end

  end

end
