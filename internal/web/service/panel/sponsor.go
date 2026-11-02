package panel

// Sponsor is a stub. The upstream sponsor feature is disabled in this fork.
type Sponsor struct {
	ID     string   `json:"id"`
	Name   string   `json:"name"`
	Enable *bool    `json:"enable,omitempty"`
	Slots  []string `json:"slots"`
}

// SponsorList is a stub.
type SponsorList struct {
	Sponsors []Sponsor `json:"sponsors"`
}

// GetSponsors is a stub that returns an empty list without any network request.
func (s *PanelService) GetSponsors() (*SponsorList, error) {
	return &SponsorList{Sponsors: []Sponsor{}}, nil
}

// GetSponsorLogo is a stub that returns an empty image without any network request.
func (s *PanelService) GetSponsorLogo(name string) ([]byte, string, error) {
	return []byte{}, "image/png", nil
}
