# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  category_id :integer
#

require 'spec_helper'

describe Product do
  it_behaves_like Slugable do
    subject { FactoryGirl.create :product, name: "momé dad hOme" }
  end

  subject { FactoryGirl.create :product }

  context 'when create' do
    it 'fails without name' do
      FactoryGirl.build(:product, name: "").should_not be_valid
    end

    it 'fails if the name is already taken' do
      FactoryGirl.build(:product, name: subject.name).should_not be_valid
    end

    it 'fails if the description is too long' do
      FactoryGirl.build(:product, description: "1000"*1000).should_not be_valid
    end
  end


  describe '#starred_asset' do

    context 'with assets' do
      let(:asset) { FactoryGirl.create :product_asset, product: subject, starred: true }

      it 'return the starred asset' do
        asset
        subject.starred_asset.model.id.should == asset.id
      end
    end

    context 'with no assets' do

      it 'return nil' do
        subject.starred_asset.should == nil
      end
    end
  end

  describe '#has_maximum_upload?' do

    context 'with already too many assets' do
      let(:asset) { FactoryGirl.create :product_asset, product: subject }
      let(:asset2) { FactoryGirl.create :product_asset, product: subject }

      it 'return true' do
        asset
        asset2
        subject.has_maximum_upload?.should == true
      end
    end

    context 'without too many assets' do

      it 'return false' do
        subject.has_maximum_upload?.should == false
      end
    end
  end

  describe '#last_messages' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, owner: user2 }

    it 'returns empty' do
      user
      subject.last_messages.should == []
    end

    context 'with two messages' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }

      it 'returns array of messages' do
        msg
        msg2
        subject.last_messages.should == [msg, msg2]
      end
    end

    context 'with two messages which has already been respond' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }
      let(:msg3) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user3.id, content: 'test2', product_id: subject.id }
      let(:msg4) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user.id, content: 'test1', product_id: subject.id }
      let(:msg5) { FactoryGirl.create :message,  sender_id: user.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }

      it 'returns array of messages' do
        msg
        msg2
        msg3
        msg4
        msg5
        subject.last_messages.should == [msg5, msg3]
      end
    end
  end

  describe '#potential_buyers_ids' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, owner: user2 }

    it 'returns empty array' do
      user
      subject.send(:potential_buyers_ids).should == []
    end

    context 'with two messages' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }

      it 'returns the senders' do
        msg
        msg2
        subject.send(:potential_buyers_ids).should == [user.id, user3.id]
      end
    end

    context 'with one message which has already been respond' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }
      let(:msg3) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user3.id, content: 'test2', product_id: subject.id }
      let(:msg4) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user.id, content: 'test1', product_id: subject.id }

      it 'returns the senders' do
        msg
        msg2
        msg3
        msg4
        subject.send(:potential_buyers_ids).should == [user.id, user3.id]
      end
    end
  end

  describe '#pending_messages_count_for_owner' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, owner: user2 }

    it 'returns 0' do
      user
      subject.pending_messages_count_for_owner.should == 0
    end

    context 'with two messages' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }

      it 'returns 2' do
        msg
        msg2
        subject.pending_messages_count_for_owner.should == 2
      end
    end

    context 'with one message which has already been respond' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', product_id: subject.id }
      let(:msg3) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user3.id, content: 'test2', product_id: subject.id }
      let(:msg4) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user.id, content: 'test1', product_id: subject.id }

      it 'returns 0' do
        msg
        msg2
        msg3
        msg4
        subject.pending_messages_count_for_owner.should == 0
      end
    end
  end

  describe '#last_message_with' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, owner: user2 }

    it 'returns nil' do
      subject.last_message_with(user).should == nil
    end

    context 'with message' do
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', product_id: subject.id }

      it 'returns the message' do
        msg
        subject.last_message_with(user).should == msg
      end
    end
  end  
end
