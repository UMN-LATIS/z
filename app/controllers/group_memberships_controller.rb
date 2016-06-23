class GroupMembershipsController < ApplicationController
	before_action :set_params, only: [:show, :index, :update, :create, :destroy]


	def index
	end

	def new
		@results = UserDataService.search_for_user_data

		respond_to do |format|
			format.html
			format.js   { render :layout => false }
		end

	end

	def create

		# if user exists in Z just hydrate and assign to group

		# else create the User then assign


		member = User.create(:uid => params[:uid])
		@group.add_user(member)



		respond_to do |format|
			if @group.has_user?(member)
			#	format.html { redirect_to 'index', notice: 'Member was successfully added to group.' }
		#		format.json { render :index, status: :created, location: @group }
				format.js   { render inline: "location.reload();"  }
			else
				format.html { render :new }
				format.json { render json: @group.errors, status: :unprocessable_entity }
				format.js   { render :edit }
			end
		end
	end


	def destroy
		@member = User.find(params[:id])
		@group.remove_user(@member)
		respond_to do |format|
			format.html { redirect_to groups_url, notice: 'Group was successfully updated, user removed.' }
			format.json { head :no_content }
			format.js   { render :layout => false }
		end

	end	

private

	def set_params
		@group = Group.find(params[:group_id])
		@group_identifier = @group.id
		@members = @group.users
	end




end
