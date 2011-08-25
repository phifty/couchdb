require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe CouchDB::UserDatabase do

  before :each do
    @server = CouchDB::Server.new "localhost", 5984, "test", "test"
    @server.password_salt = "salt"

    @user_database = @server.user_database
  end

  describe "#users" do

    before :each do
      @user = CouchDB::User.new @user_database
      @user.name = "test_user"
      @user.password = "test"
      @user.save
    end

    it "should return an array of all uses" do
      users = @user_database.users
      users.should == [ @user ]
    end

  end

end
