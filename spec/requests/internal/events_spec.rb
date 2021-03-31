describe "#index" do
  before { get mailing_list_steps_path(query: "param") }
  subject { response }
  it { is_expected.to redirect_to(mailing_list_step_path({ id: :name, query: "param" })) }
end
