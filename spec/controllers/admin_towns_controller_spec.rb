require 'spec_helper'

describe Admin::TownsController do

  before :each do
    sign_in User.create!(name: 'hello', admin: true, email: 'lol@biz.info', password: 'irrelevant')
  end

  describe "#update" do
    let(:town){ Town.new(id: 123) }
    before{ 
      Town.stub(:find).and_return(town) 
      town.stub(id: 123)
    }

    let(:params){ { id: 123, town: {name: 'new town'} } }

    context "that works" do
      before{ 
        Town.any_instance.stub(update_attributes: true)
      }

      it "purges the cache" do
        controller.should_receive(:purge_all_pages)
        post :update, params
      end

      it "redirects to the show path" do
        post :update, params
        response.should redirect_to(admin_town_path(town))
      end
    
      it "responds to html" do
        post :update, params.merge(format: :html)
        expect(response.content_type).to eq('text/html')
      end

      it "responds to json" do
        post :update, params.merge(format: :json)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "that doesn't work" do
      before{ 
        Town.any_instance.stub(update_attributes: false)
      }

      it "does not purge the cache" do
        controller.should_not_receive(:purge_all_pages)
        post :update, params
      end

      context "a html request" do
        before{ params[:format] = :html }
  
        it "rerenders the edit path" do
          post :update, params
          response.should render_template(:edit)
        end
    
        it "responds with html" do
          post :update, params.merge(format: :html)
          expect(response.content_type).to eq('text/html')
        end
      end

      context "a json request" do
        before{ params[:format] = :json }
        it "responds to json" do
          post :update, params.merge(format: :json)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

  end

  describe "#create" do
    let(:params){ { town: {name: 'new town'} } }

    context "that saves ok" do
      it "creates a town" do
        expect{ 
          post :create, params
        }.to change { Town.count }.by(1)
      end

      it "purges the cache" do
        controller.should_receive(:purge_all_pages)
        post :create, params
      end

      it "redirects to the show path" do
        post :create, params
        response.should redirect_to(admin_town_path(assigns(:town)))
      end

      it "responds to html" do
        post :create, params.merge(format: :html)
        expect(response.content_type).to eq('text/html')
      end

      it "responds to json" do
        post :create, params.merge(format: :json)
        expect(response.content_type).to eq('application/json')
      end
    end
    context "that doesn't save ok" do
      before{ Town.any_instance.stub(save: false) }
      
      it "does not create a town" do
        expect{ 
          post :create, params
        }.to_not change { Town.count }
      end

      it "does not purge the cache" do
        controller.should_not_receive(:purge_all_pages)
        post :create, params
      end

      it "rerenders the new template" do
        post :create, params
        response.should render_template(:new)
      end

      it "responds to html" do
        post :create, params.merge(format: :html)
        expect(response.content_type).to eq('text/html')
      end

      describe "a json request" do
        it "responds with json" do
          post :create, params.merge(format: :json)
          expect(response.content_type).to eq('application/json')
        end

        it "returns unprocessable_entity status" do
          post :create, params.merge(format: :json)
          expect(response.status).to eq(422)
        end
      end
    end
  end


  it "purges the cache when a town is destroyed" do
    at = Town.create!
    expect {
      controller.should_receive(:purge_all_pages)
      post :destroy, id: at.id
      response.should redirect_to(admin_towns_path)
    }.to change { Town.count }.by(-1)
  end

  describe "#index" do
    it "assigns all towns to @towns" do
      get :index
      expect(assigns[:towns]).to eq(Town.all)
    end

    it "responds to html" do
      get :index, format: :html
      expect(response.content_type).to eq('text/html')
    end

    it "responds to json" do
      get :index, format: :json
      expect(response.content_type).to eq('application/json')
    end
  end

  describe "#show" do
    let(:mock_town){ Town.new(id: 123, name: 'mock town') }
    before{ 
      Town.stub(:find).and_return(mock_town)
    }

    it "gets the right town" do
      Town.should_receive(:find).with('123').and_return(mock_town)
      get :show, id: 123
    end

    it "assigns the town" do
      get :show, id: 123
      expect(assigns[:town]).to eq(mock_town)
    end

    it "responds to html" do
      get :show, id: 123, format: :html
      expect(response.content_type).to eq('text/html')
    end

    it "responds to json" do
      get :show, id: 123, format: :json
      expect(response.content_type).to eq('application/json')
    end
  end

  describe "#new" do

    it "assigns a new town" do
      get :new
      expect(assigns[:town]).to be_a(Town)
    end


    it "responds to html" do
      get :new, format: :html
      expect(response.content_type).to eq('text/html')
    end

    it "responds to json" do
      get :new, format: :json
      expect(response.content_type).to eq('application/json')
    end
  end

  describe "#edit" do
    let(:mock_town){ Town.new(id: 123, name: 'mock town') }
    before{ 
      Town.stub(:find).and_return(mock_town)
    }

    it "gets the right town" do
      Town.should_receive(:find).with('123').and_return(mock_town)
      get :edit, id: 123
    end
  end

  it "purges the cache when a town is destroyed" do
    at = Town.create!
    expect {
      controller.should_receive(:purge_all_pages)
      post :destroy, id: at.id
      response.should redirect_to(admin_towns_path)
    }.to change { Town.count }.by(-1)
  end

  it "purges the cache when an object is destroyed" do
    object = Town.create!
    expect {
      controller.should_receive(:purge_all_pages)
      post :destroy, id: object.id
      response.should redirect_to(admin_towns_path)
    }.to change { Town.count }.by(-1)
  end
end
